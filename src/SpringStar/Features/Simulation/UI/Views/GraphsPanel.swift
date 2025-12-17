//
//  GraphsPanel.swift
//  SpringStar
//
//  Created by Ashworth, Jack on 12/16/25.
//

import SwiftUI

struct GraphsPanel: View {
    @ObservedObject var viewModel: SimulationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Graphs
            VStack(spacing: 12) {
                // If more than one of displacement/velocity is enabled, show combined view
                let enabledCount = (viewModel.showDisplacement ? 1 : 0) + (viewModel.showVelocity ? 1 : 0)

                if enabledCount > 1 {
                    CombinedLineGraphView(
                        graphStore: viewModel.graphStore,
                        playbackTime: viewModel.playbackTime,
                        title: "Mass-Spring-Damper System Simulation (Runge-Kutta)",
                        showDisplacement: viewModel.showDisplacement,
                        showVelocity: viewModel.showVelocity
                    )
                } else {
                    if viewModel.showDisplacement {
                        LineGraphView(
                            samples: viewModel.graphStore.samples,
                            metric: .displacement,
                            playbackTime: viewModel.playbackTime,
                            title: "Displacement"
                        )
                    }

                    if viewModel.showVelocity {
                        LineGraphView(
                            samples: viewModel.graphStore.samples,
                            metric: .velocity,
                            playbackTime: viewModel.playbackTime,
                            title: "Velocity"
                        )
                    }

                    // Acceleration view intentionally omitted to focus on displacement/velocity
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .frame(maxWidth: 900) // adjust width to taste
    }
}
