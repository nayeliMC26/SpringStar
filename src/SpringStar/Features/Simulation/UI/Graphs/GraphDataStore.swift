//
//  GraphDataStore.swift
//  SpringStar
//
//  Created by Seth & Jelly on 9/29/25.
//

import Foundation
import Combine
import SwiftUI

/// Lightweight, parameter-driven signal generator for graphs (no real physics yet).
/// Produces displacement y(t), velocity v(t), and a(t) using the textbook SMD formulas.
final class GraphDataStore: ObservableObject {
    @Published var time: [Double] = []
    @Published var y: [Double] = []
    @Published var v: [Double] = []
    @Published var a: [Double] = []

    // Playback / progress
    @Published var isRunning: Bool = false
    @Published var elapsed: Double = 0       // seconds
    @Published var duration: Double = 30    // seconds shown in the slider
    @Published var progress: Double = 0      // 0...1, bound to the playback slider (scrub)

    private var displayLink: CADisplayLink?
    private var lastTick: CFTimeInterval = CACurrentMediaTime()
    private let maxSamples = 3_000

    // Current “render” parameters → read from SimulationViewModel whenever they change
    struct Params {
        var m: Double, c: Double, k: Double
        var y0: Double, v0: Double
        enum Forcing { case none, sinusoid(A: Double, fHz: Double), constant(Double) }
        var forcing: Forcing
    }
    var params = Params(m: 1, c: 0.2, k: 15, y0: 0.1, v0: 0, forcing: .none)

    func start() {
        guard !isRunning else { return }
        isRunning = true
        lastTick = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.preferredFrameRateRange = .init(minimum: 30, maximum: 120, preferred: 60)
        displayLink = link
        link.add(to: .current, forMode: .common)
    }

    func stop() {
        isRunning = false
        displayLink?.invalidate()
        displayLink = nil
    }

    func reset() {
        stop()
        elapsed = 0
        progress = 0
        time.removeAll(keepingCapacity: true)
        y.removeAll(keepingCapacity: true)
        v.removeAll(keepingCapacity: true)
        a.removeAll(keepingCapacity: true)
    }
    
    func rewind(seconds: Double) {
        // No samples → nothing to rewind
        guard !time.isEmpty else { return }

        let currentTime = time.last ?? 0
        let targetTime = max(0, currentTime - seconds)

        // Find the last sample at or before targetTime
        let idx = time.lastIndex(where: { $0 <= targetTime }) ?? 0

        // Trim arrays so future samples continue from there
        if idx + 1 < time.count {
            time.removeSubrange((idx+1)..<time.count)
            y.removeSubrange((idx+1)..<y.count)
            v.removeSubrange((idx+1)..<v.count)
            a.removeSubrange((idx+1)..<a.count)
        }

        // Update elapsed + progress to match new time
        elapsed = targetTime
        if duration > 0 {
            progress = (elapsed.truncatingRemainder(dividingBy: duration)) / duration
        } else {
            progress = 0
        }
    }

    func updateParams(_ p: Params) { params = p }

    @objc private func tick(_ link: CADisplayLink) {
        guard isRunning else { return }
        let now = CACurrentMediaTime()
        let dt = now - lastTick
        lastTick = now

        // Accumulate elapsed wall-clock time (for graphs)
        elapsed += dt

        // Append one or a few samples per tick to smooth out render variance
        let steps = max(1, Int((dt * 60).rounded()))
        let h = max(1.0/240.0, dt / Double(steps))

        for _ in 0..<steps {
            let t = (time.last ?? 0) + h
            let sample = sampleSMD(t: t, p: params)
            time.append(t); y.append(sample.y); v.append(sample.v); a.append(sample.a)
        }

        // Trim arrays to cap memory
        trim(&time); trim(&y); trim(&v); trim(&a)

        // Update normalized slider progress (0...1) mapped to a rolling window [0, duration]
        if duration > 0 { progress = (elapsed.truncatingRemainder(dividingBy: duration)) / duration }
    }

    private func trim(_ a: inout [Double]) {
        if a.count > maxSamples { a.removeFirst(a.count - maxSamples) }
    }

    /// Textbook mass–spring–damper "look-alike" signals (not the real integrator yet).
    private func sampleSMD(t: Double, p: Params) -> (y: Double, v: Double, a: Double) {
        // Natural frequency, damping ratio
        let wn = sqrt(max(0, p.k / max(p.m, 1e-6)))
        let zeta = p.c / (2 * sqrt(max(1e-6, p.m * p.k)))

        // Base response to initial conditions (homogeneous solution)
        var yy: Double = 0, vv: Double = 0
        if zeta < 1 - 1e-5 {
            // Underdamped
            let wd = wn * sqrt(1 - zeta*zeta)
            let A = p.y0
            // Pick B from v0 (B * wd at t=0 plus -zeta*wn*A piece)
            let B = (p.v0 + zeta*wn*A) / wd
            let e = exp(-zeta*wn*t)
            yy = e * (A * cos(wd*t) + B * sin(wd*t))
            vv = e * ( -A*wd * sin(wd*t) + B*wd * cos(wd*t) ) - zeta*wn*yy
        } else if zeta > 1 + 1e-5 {
            // Overdamped
            let r1 = -wn*(zeta - sqrt(zeta*zeta - 1))
            let r2 = -wn*(zeta + sqrt(zeta*zeta - 1))
            // Solve constants for y(0)=y0, y'(0)=v0
            let c2 = (p.v0 - r1*p.y0) / (r2 - r1)
            let c1 = p.y0 - c2
            yy = c1*exp(r1*t) + c2*exp(r2*t)
            vv = c1*r1*exp(r1*t) + c2*r2*exp(r2*t)
        } else {
            // Critically damped
            let c1 = p.y0
            let c2 = p.v0 + wn*p.y0
            yy = (c1 + c2*t) * exp(-wn*t)
            vv = (c2 - wn*(c1 + c2*t)) * exp(-wn*t)
        }

        // Very light “forcing” spice so the sliders feel responsive before real physics:
        switch p.forcing {
        case .none:
            break
        case .constant(let F):
            // Shift baseline a bit w.r.t k (static deflection F/k)
            yy += F / max(p.k, 1e-6) * 0.2
        case .sinusoid(let A, let fHz):
            yy += A * 0.2 * sin(2 * .pi * fHz * t)
        }

        // Acceleration a ≈ y'' via the ODE form: a = ( -c v - k y ) / m
        let aa = ( -p.c * vv - p.k * yy ) / max(p.m, 1e-6)
        return (yy, vv, aa)
    }
}
