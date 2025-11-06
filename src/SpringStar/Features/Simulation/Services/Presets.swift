//
//  Presets.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//
// Stores preset values for functions based on what was given by the client

import Foundation

//TODO: Update witht he new info from client 

// Preset values for the system
struct Preset {
    let name: String
    let params: SystemParams
    let y0: Float
    let v0: Float
}

enum Presets {
    static func overdamped(mass: Float = 1, stiffness: Float = 15) -> Preset {
        let ccrit = 2 * sqrt(mass * stiffness)
        let params = SystemParams(mass: mass, damping: 1.5 * ccrit, stiffness: stiffness, restLength: 0.5, forcing: .none)
        return Preset(name: "Over", params: params, y0: 0.1, v0: 0)
    }

    static func criticallyDamped(mass: Float = 1, stiffness: Float = 15) -> Preset {
        let ccrit = 2 * sqrt(mass * stiffness)
        let params = SystemParams(mass: mass, damping: ccrit, stiffness: stiffness, restLength: 0.5, forcing: .none)
        return Preset(name: "Crit", params: params, y0: 0.1, v0: 0)
    }

    static func underdamped(mass: Float = 1, stiffness: Float = 15) -> Preset {
        let ccrit = 2 * sqrt(mass * stiffness)
        let params = SystemParams(mass: mass, damping: 0.2 * ccrit, stiffness: stiffness, restLength: 0.5, forcing: .none)
        return Preset(name: "Under", params: params, y0: 0.1, v0: 0)
    }

    static func undamped(mass: Float = 1, stiffness: Float = 15) -> Preset {
        let params = SystemParams(mass: mass, damping: 0, stiffness: stiffness, restLength: 0.5, forcing: .none)
        return Preset(name: "Undamped", params: params, y0: 0.1, v0: 0)
    }
}

