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

                if viewModel.showAcceleration {
                    LineGraphView(
                        samples: viewModel.graphStore.samples,
                        metric: .acceleration,
                        playbackTime: viewModel.playbackTime,
                        title: "Acceleration"
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .frame(maxWidth: 900) // adjust width to taste
    }
}
