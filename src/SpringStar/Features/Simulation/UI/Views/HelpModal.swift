//
//  HelpModal.swift
//  SpringStar
//
//  It contains UI elements for the help modal
//  Created by Jelly on 9/29/25.
//

//TODO: Add some indicators for where you can actually "help" so for example if the modal shows help with something on the playback controls, then the program should highlight or indicate this somehow

import SwiftUI

struct HelpModal: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SpringStar Help").font(.title2).bold()
                Spacer()
                Button("Close") { isPresented = false }
            }
            Divider()
            Text("Use the sliders to set mass (m), damping (c), and stiffness (k). \nStart begins the simulation; Reset stops and zeros parameters. \nPresets set typical damping regimes. Forcing functions can be added via the dropdown.")
                .font(.body)
            Spacer()
        }
        .padding(24)
        .frame(width: 520, height: 360)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 12)
    }
}

