//
//  SystemParams.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//

import Foundation

public struct SystemParams {
    public var mass: Float         // m
    public var damping: Float      // c
    public var stiffness: Float    // k
    public var restLength: Float   // L0
    public var forcing: Forcing

    public init(
        mass: Float = 1.0,
        damping: Float = 0.2,
        stiffness: Float = 15.0,
        restLength: Float = 0.5,
        forcing: Forcing = .none
    ) {
        self.mass = mass
        self.damping = damping
        self.stiffness = stiffness
        self.restLength = restLength
        self.forcing = forcing
    }
}

