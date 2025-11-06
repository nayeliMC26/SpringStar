//
//  SimulationController.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//

import Foundation
import RealityKit

/// A lightweight controller that manages a procedural spring entity.
final class SimulationController {
    private let renderer: ProcSpringRenderer

    init(renderer: ProcSpringRenderer = ProcSpringRenderer()) {
        self.renderer = renderer
    }

    /// Returns the existing spring entity or creates one if needed.
    func makeEntity() throws -> ModelEntity? {
        try renderer.makeEntityIfNeeded()
    }
}
