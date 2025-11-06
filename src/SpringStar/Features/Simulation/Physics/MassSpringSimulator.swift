//
//  MassSpringSimulator.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//

import Foundation

public struct MassSpringSimulator: Simulator {
    public var params: SystemParams
    public private(set) var state: SystemState

    public init(params: SystemParams = SystemParams()) {
        self.params = params
        self.state = SystemState()
    }

    public mutating func step(dt: Float) {
        state.time += dt
    }

    public mutating func reset(time: Float, displacement: Float, velocity: Float) {
        state.time = time
        state.displacement = displacement
        state.velocity = velocity
    }
}
