//
//  PlaybackBar.swift
//  SpringStar
//
//  It contains UI elements for the playback bar which will allow users to scrub through the history of a simulation
//  Created by Jelly on 9/29/25.
//

import SwiftUI

struct PlaybackBar: View {
    @ObservedObject var viewModel: SimulationViewModel

    var body: some View {
        HStack(spacing: 16) {
            Button(action: { viewModel.isRunning ? viewModel.stop() : viewModel.start() }) {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.bordered)

            Button(action: { viewModel.reset() }) {
                Image(systemName: "backward.end.alt")
            }
            .buttonStyle(.bordered)

            Slider(value: .constant(0.0))
                .disabled(true)
                .frame(maxWidth: 400)

            Text("00:00")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

