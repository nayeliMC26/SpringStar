//
//  SpringStarApp.swift
//  SpringStar
//
//  Created by Jelly on 9/17/25.
//

import SwiftUI

@main
struct SpringStarApp: App {
    @State private var hasStarted = false

    var body: some Scene {
        WindowGroup {
            if hasStarted {
                SimulationView()
            } else {
                WelcomeView {
                    hasStarted = true
                }
            }
        }
        .windowStyle(.volumetric)
    }
}

