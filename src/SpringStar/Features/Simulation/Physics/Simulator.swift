//
//  Simulator.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//

import Foundation

public protocol Simulator {
    mutating func step(dt: Float)
}

