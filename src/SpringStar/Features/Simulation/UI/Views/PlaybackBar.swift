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

            Button {
                viewModel.isRunning ? viewModel.stop() : viewModel.start()
            } label: {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.bordered)

            Button {
                viewModel.reset()
            } label: {
                Image(systemName: "backward.end.alt")
            }
            .buttonStyle(.bordered)

            // Rewind 10 seconds
            Button {
                viewModel.rewind10Seconds()
            } label: {
                Image(systemName: "gobackward.10")
            }
            .buttonStyle(.bordered)

            // Playback scrubber
            Slider(
                value: $viewModel.playbackTime,
                in: 0...max(viewModel.maxPlaybackTime, 0.01),
                onEditingChanged: { editing in
                    viewModel.isScrubbing = editing
                    if !editing {
                        viewModel.scrub(to: viewModel.playbackTime)
                    }
                }
            )
            .frame(maxWidth: 420)

            Text(timeString(viewModel.playbackTime))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private func timeString(_ t: Double) -> String {
        let total = max(0, Int(t.rounded()))
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}


