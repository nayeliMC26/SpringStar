//
//  SystemState.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//

import Foundation

public struct SystemState {
    public var time: Float    // t
    public var displacement: Float // y (height ext from rest)
    public var velocity: Float     // v

    public init(time: Float = 0, displacement: Float = 0, velocity: Float = 0) {
        self.time = time
        self.displacement = displacement
        self.velocity = velocity
    }
}

