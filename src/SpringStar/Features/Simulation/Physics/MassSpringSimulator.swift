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

    /// Advance the system by dt seconds using RK4 integration.
    /// State variables:
    /// x' = v
    /// v' = (F(t) - c v - k x) / m
    public mutating func step(dt: Float) {
        let m = params.mass
        let c = params.damping
        let k = params.stiffness

        // Early out if dt is non-positive or mass is invalid
        guard dt > 0, m > 0 else {
            state.time += max(0, dt)
            return
        }

        let t0 = state.time
        let x0 = state.displacement
        let v0 = state.velocity

        func force(_ t: Float) -> Float { params.forcing.value(atTime: t) }
        func accel(_ t: Float, _ x: Float, _ v: Float) -> Float {
            let F = force(t)
            return (F - c * v - k * x) / m
        }

        // Apply an impulse kick at the beginning of the step if it occurs within this interval.
        var vInitial = v0
        if let impulse = params.forcing.impulseKick(from: t0, dt: dt) {
            vInitial += impulse / m
        }
        let vStart = vInitial

        // k1
        let k1x = vStart
        let k1v = accel(t0, x0, vStart)

        // k2 (midpoint)
        let x_mid1 = x0 + 0.5 * dt * k1x
        let v_mid1 = vStart + 0.5 * dt * k1v
        let t_mid = t0 + 0.5 * dt
        let k2x = v_mid1
        let k2v = accel(t_mid, x_mid1, v_mid1)

        // k3 (midpoint using k2)
        let x_mid2 = x0 + 0.5 * dt * k2x
        let v_mid2 = vStart + 0.5 * dt * k2v
        let k3x = v_mid2
        let k3v = accel(t_mid, x_mid2, v_mid2)

        // k4 (endpoint)
        let x_end = x0 + dt * k3x
        let v_end = vStart + dt * k3v
        let t_end = t0 + dt
        let k4x = v_end
        let k4v = accel(t_end, x_end, v_end)

        // Combine increments
        let x_next = x0 + (dt / 6) * (k1x + 2 * k2x + 2 * k3x + k4x)
        let v_next = vStart + (dt / 6) * (k1v + 2 * k2v + 2 * k3v + k4v)

        state.time = t_end
        state.displacement = x_next
        state.velocity = v_next
    }

    public mutating func reset(time: Float, displacement: Float, velocity: Float) {
        state.time = time
        state.displacement = displacement
        state.velocity = velocity
    }
}
