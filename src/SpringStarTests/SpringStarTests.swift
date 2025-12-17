//
//  SpringStarTests.swift
//  SpringStarTests
//
//  Created by Jelly on 9/17/25.
//

import Foundation
import Testing

@testable import SpringStar

final class SpringStarTests {

    /// Validate RK4 for undamped, unforced oscillator matches analytic cos(ωt)
    @Test func rk4_matches_analytic_simple_harmonic_motion() async throws {
        // System: m = 1, c = 0, k = 1 → ω = 1 rad/s, period T = 2π
        let params = SystemParams(
            mass: 1.0,
            damping: 0.0,
            stiffness: 1.0,
            restLength: 0.0,
            forcing: .none
        )
        var sim = MassSpringSimulator(params: params)
        // Initial conditions: x(0) = 1, v(0) = 0
        sim.reset(time: 0, displacement: 1, velocity: 0)

        let twoPi = Float.pi * 2
        let totalTime: Float = twoPi  // one period
        let dt: Float = 0.001
        let steps = Int(totalTime / dt)
        for _ in 0..<steps { sim.step(dt: dt) }

        // Analytic solution at t = 2π: x = cos(2π) = 1, v = -sin(2π) = 0
        let xExpected: Float = 1
        let vExpected: Float = 0
        let xErr = abs(sim.state.displacement - xExpected)
        let vErr = abs(sim.state.velocity - vExpected)

        #expect(xErr < 1e-3, "Displacement error too large: \(xErr)")
        #expect(vErr < 1e-2, "Velocity error too large: \(vErr)")
    }

    /// Runs the simulation and returns (time, displacement, velocity) for each step
    func runPresetTest(_ preset: Preset, dt: Float = 0.01, tEnd: Float = 10.0)
        -> [(Float, Float, Float)]
    {
        var sim = MassSpringSimulator(params: preset.params)
        sim.reset(time: 0, displacement: preset.y0, velocity: preset.v0)

        let steps = Int(tEnd / dt)
        var results: [(Float, Float, Float)] = [(0, preset.y0, preset.v0)]

        for _ in 0..<steps {
            sim.step(dt: dt)
            results.append(
                (sim.state.time, sim.state.displacement, sim.state.velocity)
            )
        }

        return results
    }

    /// Format the results for comparison with the Python notebook provided by client
    func resultsText(
        _ name: String,
        _ results: [(Float, Float, Float)],
        dt: Float = 0.01
    ) -> String {
        var text = "\n=== \(name) ===\nTime\tDisplacement\tVelocity\n"
        let interval = max(1, Int(1.0 / dt))
        for i in stride(from: 0, to: results.count, by: interval) {
            let (t, x, v) = results[i]
            text += String(format: "%.1f\t%.6f\t%.6f\n", t, x, v)
        }
        return text
    }

    @Test func testOverdampedPreset() async throws {
        let results = runPresetTest(Presets.overdamped())
        print(resultsText("Overdamped", results))
    }

    @Test func testCriticallyDampedPreset() async throws {
        let results = runPresetTest(Presets.criticallyDamped())
        print(resultsText("Critically Damped", results))
    }

    @Test func testUnderdampedPreset() async throws {
        let results = runPresetTest(Presets.underdamped())
        print(resultsText("Underdamped", results))
    }

    @Test func testUndampedPreset() async throws {
        let results = runPresetTest(Presets.undamped())
        print(resultsText("Undamped", results))
    }
}
