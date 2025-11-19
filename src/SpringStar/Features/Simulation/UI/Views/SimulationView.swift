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

struct SimulationView: View {
    @StateObject private var viewModel = SimulationViewModel()

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 12) {
                HStack(alignment: .top, spacing: 24) {
                    RealityView { content in
                        if let entity = try? viewModel.renderer.makeEntityIfNeeded() {
                            if viewModel.renderer.modelEntity === entity {
                                entity.position = [0, 0, -0.3]
                                content.add(entity)
                            }
                        }
                    } update: { _ in
                        // (Later) set entity.position.y = viewModel.height for live physics
                    }
                    .frame(width: 700, height: 700)

                    SidebarView(viewModel: viewModel)
                        .frame(width: 360)
                        .zIndex(2)
                }

                // Playback controls
                PlaybackBar(viewModel: viewModel)
                    .padding(.top, 4)

                // Graphs (react to sidebar toggles and parameters)
                VStack(spacing: 10) {
                    if viewModel.showDisplacement {
                        LineGraphView(
                            seconds: viewModel.timeSeries,
                            series: [.init( name: "y(t)", values: viewModel.displacementSeries)],
                            height: 160,
                            cursor01: viewModel.playbackProgress
                        )
                    }
                    if viewModel.showVelocity {
                        LineGraphView(
                            seconds: viewModel.timeSeries,
                            series: [.init(name: "v(t)", values: viewModel.velocitySeries)],
                            height: 160,
                            cursor01: viewModel.playbackProgress
                        )
                    }
                    if viewModel.showAcceleration {
                        LineGraphView(
                            seconds: viewModel.timeSeries,
                            series: [.init(name: "a(t)", values: viewModel.accelerationSeries)],
                            height: 160,
                            cursor01: viewModel.playbackProgress
                        )
                    }
                }
                .padding(.top, 6)

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

