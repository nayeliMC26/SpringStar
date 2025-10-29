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
    case sinusoid(amplitude: Float, frequencyHz: Float, phase: Float = 0)
    case constant(Float)

    public func value(atTime t: Float) -> Float {
        switch self {
        case .none:
            return 0
        case let .sinusoid(amplitude, frequencyHz, phase):
            return amplitude * sin(2 * .pi * frequencyHz * t + phase)
        case let .constant(v):
            return v
        }
    }
}

