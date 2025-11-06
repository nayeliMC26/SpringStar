//
//  SidebarView.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//
//  It contains UI elements for starting/stopping the simulation, adjusting system parameters,
//  selecting presets, and viewing forcing/graphing options.
//

import SwiftUI

/// SidebarView — a control panel that displays simulation controls and parameter sliders.
struct SidebarView: View {
    /// The view model that drives the simulation state and parameters.
    /// SwiftUI updates the UI automatically when any @Published properties change.
    @ObservedObject var viewModel: SimulationViewModel

    /// Controls visibility of the Help modal sheet.
    @State private var showHelp: Bool = false

    var body: some View {
        // The sidebar layout: a vertical stack of controls and sections.
        VStack(alignment: .leading, spacing: 16) {

            // --- Simulation Control Buttons (Start / Stop / Reset) ---
            HStack {
                // Start or Stop button (toggles depending on simulation state)
                Button(viewModel.isRunning ? "Stop" : "Start") {
                    viewModel.isRunning ? viewModel.stop() : viewModel.start()
                }
                .buttonStyle(.borderedProminent)

                // Reset button — resets the simulation to its initial conditions
                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 12)

            // --- System Parameter Controls: mass (m), damping (c), stiffness (k) ---

            // Mass (m)
            Text("m").font(.title3).bold()
            Slider(value: $viewModel.mass, in: 0.0...5.0, onEditingChanged: { _ in
                viewModel.applyParamsImmediately()
            })
            Text(String(format: "%.2f", viewModel.mass))
                .font(.caption)
                .foregroundColor(.secondary)

            // Damping coefficient (c)
            Text("c").font(.title3).bold()
            Slider(value: $viewModel.damping, in: 0.0...5.0, onEditingChanged: { _ in
                viewModel.applyParamsImmediately()
            })
            Text(String(format: "%.2f", viewModel.damping))
                .font(.caption)
                .foregroundColor(.secondary)

            // Spring stiffness (k)
            Text("k").font(.title3).bold()
            Slider(value: $viewModel.stiffness, in: 0.0...50.0, onEditingChanged: { _ in
                viewModel.applyParamsImmediately()
            })
            Text(String(format: "%.2f", viewModel.stiffness))
                .font(.caption)
                .foregroundColor(.secondary)

            // --- Preset configurations for the spring system ---
            Picker("Presets", selection: $viewModel.selectedPreset) {
                Text("None").tag(SimulationViewModel.PresetType.none)
                Text("Over").tag(SimulationViewModel.PresetType.over)
                Text("Crit").tag(SimulationViewModel.PresetType.crit)
                Text("Under").tag(SimulationViewModel.PresetType.under)
                Text("Undamped").tag(SimulationViewModel.PresetType.undamped)
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedPreset) { _, _ in
                viewModel.applySelectedPreset()
            }

            // --- Initial Conditions (displacement y0 and velocity v0) ---
            Text("Initial Conditions").font(.title3)

            // Initial displacement slider
            Slider(value: $viewModel.initialDisplacement, in: -0.25...0.25, onEditingChanged: { _ in
                viewModel.previewInitialConditionsIfIdle()
            })
            Text("y0: " + String(format: "%.2f", viewModel.initialDisplacement))
                .font(.title3)
                .foregroundColor(.secondary)

            // Initial velocity slider
            Slider(value: $viewModel.initialVelocity, in: -1.0...1.0)
            Text("v0: " + String(format: "%.2f", viewModel.initialVelocity))
                .font(.caption)
                .foregroundColor(.secondary)

            Divider().padding(.vertical, 8)

            // --- Forcing Function Controls ---
            Text("Forcing Function").font(.title3)

            // Picker to select type of forcing function
            Picker("Forcing", selection: $viewModel.forcingType) {
                Text("None").tag(SimulationViewModel.ForcingType.none)
                Text("Sinusoid").tag(SimulationViewModel.ForcingType.sinusoid)
                Text("Constant").tag(SimulationViewModel.ForcingType.constant)
            }
            .pickerStyle(.menu)

            // Dynamic UI based on the selected forcing type
            switch viewModel.forcingType {
            case .none:
                EmptyView()

            case .sinusoid:
                // Sinusoidal forcing parameters
                Text("Amplitude").font(.subheadline)
                Slider(value: $viewModel.sinusoidAmplitude, in: 0...2, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.sinusoidAmplitude))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Frequency (Hz)").font(.subheadline)
                Slider(value: $viewModel.sinusoidFrequencyHz, in: 0.1...5, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.sinusoidFrequencyHz))
                    .font(.caption)
                    .foregroundColor(.secondary)

            case .constant:
                // Constant forcing parameter
                Text("Force (N)").font(.subheadline)
                Slider(value: $viewModel.constantForce, in: -5...5, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.constantForce))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider().padding(.vertical, 8)

            // --- Graph Display Options ---
            Text("Graphs").font(.title3)

            // Toggles for displaying different simulation plots
            Toggle("Displacement vs. Time", isOn: $viewModel.showDisplacement)
            Toggle("Velocity vs. Time", isOn: $viewModel.showVelocity)
            Toggle("Acceleration vs. Time", isOn: $viewModel.showAcceleration)

            // Help button aligned to the right
            HStack {
                Spacer()
                Button(action: { showHelp = true }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }
        }
        // --- Help Modal Sheet ---
        .sheet(isPresented: $showHelp) {
            HelpModal(isPresented: $showHelp)
        }

        // --- Sidebar Styling ---
        .padding(20)
        .foregroundStyle(.white)
        .background(
            ZStack {
                // Background uses blurred material with dark overlay for depth
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThickMaterial)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black.opacity(0.25))
            }
        )
        .shadow(radius: 12)
        .controlSize(.large)
    }
}
