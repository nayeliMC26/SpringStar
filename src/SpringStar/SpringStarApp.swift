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
            ZStack {
                SimulationView()

                // Present the welcome overlay until the user starts
                if !hasStarted {
                    WelcomeView {
                        withAnimation { hasStarted = true }
                    }
                    .transition(.opacity)
                    .zIndex(2)
                }
            }
        }
        .windowStyle(.volumetric)
    }
}

