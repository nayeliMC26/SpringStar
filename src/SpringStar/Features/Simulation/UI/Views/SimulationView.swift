//
//  SimulationView.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//
//  This SwiftUI view defines the main layout for the simulation screen.

//

import SwiftUI
import RealityKit

/// The main container view for the simulation scene.
struct SimulationView: View {
    /// The simulation’s view model, which manages both physics state and rendering.
    @StateObject private var viewModel = SimulationViewModel()

    var body: some View {
        ZStack {
            // A vertical layout holding the 3D scene, sidebar, and playback controls
            VStack(alignment: .center, spacing: 12) {
                // The main row: RealityKit simulation on the left, sidebar controls on the right
                HStack(alignment: .top, spacing: 24) {

                    // RealityKit 3D rendering area
                    RealityView { content in
                        // Try to build or reuse the spring entity
                        if let entity = try? viewModel.renderer.makeEntityIfNeeded() {
                            // Check if this spring matches the current renderer’s modelEntity
                            if viewModel.renderer.modelEntity === entity {
                                // Position the sprong slightly back along the z-axis for visibility
                                entity.position = [0, 0, -0.3]
                                // Add the entity to the RealityKit content scene
                                content.add(entity)
                            }
                        }
                    } update: { _ in
                        // Once we have things to update they'll update here per frame
                    }
                    .frame(width: 700, height: 700)
                    .alignmentGuide(.top) { d in d[.top] }

                    // Sidebar containing simulation controls and parameters
                    SidebarView(viewModel: viewModel)
                        .frame(width: 600)
                        .zIndex(2)
                }

                // Playback bar for time navigation and controls (below the main view)
                PlaybackBar(viewModel: viewModel)
                    .padding(.top, 12)
                    .zIndex(2)

                // Graphs under playback bar
                GraphsPanel(viewModel: viewModel)
                    .padding(.top, 8)
                    .zIndex(1)

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

