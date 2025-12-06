//
//  Forcing.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//
//TODO: Add more forcing functions from clinet

import Foundation

public enum Forcing: Equatable {
    case none
    case harmonic(amplitude: Float, frequencyHz: Float, phase: Float = 0, waveform: HarmonicWaveform = .sine)
    case sinusoid(amplitude: Float, frequencyHz: Float, phase: Float = 0) // kept for compatibility
    case constant(Float)
    case step(magnitude: Float, time: Float)
    case impulse(magnitude: Float, time: Float)

    public func value(atTime t: Float) -> Float {
        switch self {
        case .none:
            return 0
        case let .harmonic(amplitude, frequencyHz, phase, waveform):
            let theta = 2 * .pi * frequencyHz * t + phase
            return waveform == .sine ? amplitude * sin(theta) : amplitude * cos(theta)
        case let .sinusoid(amplitude, frequencyHz, phase):
            return amplitude * sin(2 * .pi * frequencyHz * t + phase)
        case let .constant(v):
            return v
        case let .step(magnitude, time):
            return t >= time ? magnitude : 0
        case .impulse:
            return 0 // handled as an instantaneous kick
        }
    }

    /// Returns the impulse magnitude if it occurs within [start, start + dt].
    public func impulseKick(from start: Float, dt: Float) -> Float? {
        guard case let .impulse(magnitude, time) = self else { return nil }
        let end = start + dt
        let tolerance = max(1e-4, dt * 0.25)
        if time + tolerance >= start && time - tolerance <= end {
            return magnitude
        }
        return nil
    }

    public enum HarmonicWaveform: String, CaseIterable, Equatable, Identifiable {
        case sine
        case cosine
        public var id: String { rawValue }
    }
}
