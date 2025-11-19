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
        HStack(spacing: 12) {
            Button(action: { viewModel.isRunning ? viewModel.stop() : viewModel.start() }) {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.borderedProminent)

            Button(action: { viewModel.reset() }) {
                Image(systemName: "backward.end.alt")
            }
            .buttonStyle(.bordered)

            Button(action: { viewModel.rewind(seconds: 10)}){
                Image(systemName: "gobackward.10")
            }
            .buttonStyle(.bordered)
            .help("Rewind 10 seconds")
            
            // Scrub cursor: maps 0...1 to a simple vertical line on the charts
            Slider(value: $viewModel.playbackProgress, in: 0...1)

            Text(viewModel.elapsedLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

