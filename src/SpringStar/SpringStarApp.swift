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
                // just hide the simulation view rather than have it active behind the welcome
                    .opacity(hasStarted ? 1 : 0)
                    .allowsHitTesting(hasStarted)

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


