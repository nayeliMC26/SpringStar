//
//  SpringStarTests.swift
//  SpringStarTests
//
//  Created by Jelly on 9/17/25.
//

import Testing
@testable import SpringStar

struct SpringStarTests {

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
        let totalTime: Float = twoPi // one period
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

}
