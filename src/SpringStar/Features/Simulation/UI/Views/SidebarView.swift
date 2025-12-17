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
            Slider(value: $viewModel.mass, in: 0.1...5.0, onEditingChanged: { _ in
                viewModel.applyParamsImmediately()
            })
            Text(String(format: "%.2f", viewModel.mass))
                .font(.headline)
                .foregroundColor(.primary)

            // Damping coefficient (c)
            Text("c").font(.title3).bold()
            Slider(value: $viewModel.damping, in: 0.0...5.0, onEditingChanged: { _ in
                viewModel.applyParamsImmediately()
            })
            Text(String(format: "%.2f", viewModel.damping))
                .font(.headline)
                .foregroundColor(.primary)

            // Spring stiffness (k)
            Text("k").font(.title3).bold()
            Slider(value: $viewModel.stiffness, in: 10.0...500.0, onEditingChanged: { _ in
                viewModel.applyParamsImmediately()
            })
            Text(String(format: "%.2f", viewModel.stiffness))
                .font(.headline)
                .foregroundColor(.primary)

            // --- Preset configurations for the spring system ---
            Picker("Presets", selection: $viewModel.selectedPreset) {
                Text("None").tag(SimulationViewModel.PresetType.none)
                Text("Overdamped").tag(SimulationViewModel.PresetType.over)
                Text("Critically damped").tag(SimulationViewModel.PresetType.crit)
                Text("Underdamped").tag(SimulationViewModel.PresetType.under)
                Text("Undamped").tag(SimulationViewModel.PresetType.undamped)
            }
            .pickerStyle(.segmented)
            .foregroundStyle(.primary)
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
                .foregroundColor(.primary)

            // Initial velocity slider
            Slider(value: $viewModel.initialVelocity, in: -1.0...1.0)
            Text("v0: " + String(format: "%.2f", viewModel.initialVelocity))
                .font(.headline)
                .foregroundColor(.primary)

            Divider().padding(.vertical, 8)

            // --- Forcing Function Controls ---
            Text("Forcing Function").font(.title3)

            // Picker to select type of forcing function
            Picker("Forcing", selection: $viewModel.forcingType) {
                Text("None").tag(SimulationViewModel.ForcingType.none)
                Text("Harmonic (sin/cos)").tag(SimulationViewModel.ForcingType.harmonic)
                Text("Step").tag(SimulationViewModel.ForcingType.step)
                Text("Impulse").tag(SimulationViewModel.ForcingType.impulse)
                Text("Constant").tag(SimulationViewModel.ForcingType.constant)
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.forcingType) { _, _ in
                viewModel.applyForcingImmediately()
            }

            // Dynamic UI based on the selected forcing type
            switch viewModel.forcingType {
            case .none:
                EmptyView()

            case .harmonic:
                // Harmonic forcing parameters
                Text("Amplitude").font(.subheadline)
                Slider(value: $viewModel.harmonicAmplitude, in: 0...5, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.harmonicAmplitude))
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Frequency (Hz)").font(.subheadline)
                Slider(value: $viewModel.harmonicFrequencyHz, in: 0.1...5, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.harmonicFrequencyHz))
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Phase (rad)").font(.subheadline)
                Slider(value: $viewModel.harmonicPhase, in: -Float.pi...Float.pi, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.harmonicPhase))
                    .font(.headline)
                    .foregroundColor(.primary)

                Picker("Waveform", selection: $viewModel.harmonicWaveform) {
                    Text("Sine").tag(Forcing.HarmonicWaveform.sine)
                    Text("Cosine").tag(Forcing.HarmonicWaveform.cosine)
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.harmonicWaveform) { _, _ in
                    viewModel.applyForcingImmediately()
                }

            case .step:
                Text("Step Magnitude (N)").font(.subheadline)
                Slider(value: $viewModel.stepMagnitude, in: -5...5, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.stepMagnitude))
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Delta T (s)").font(.subheadline)
                Slider(value: $viewModel.stepTime, in: 0...5, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.stepTime))
                    .font(.headline)
                    .foregroundColor(.primary)

            case .impulse:
                Text("Impulse (N·s)").font(.subheadline)
                Slider(value: $viewModel.impulseMagnitude, in: -5...5, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.impulseMagnitude))
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Delta T (s)").font(.subheadline)
                Slider(value: $viewModel.impulseTime, in: 0...5, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.impulseTime))
                    .font(.headline)
                    .foregroundColor(.primary)

            case .constant:
                // Constant forcing parameter
                Text("Force (N)").font(.subheadline)
                Slider(value: $viewModel.constantForce, in: -5...5, onEditingChanged: { _ in
                    viewModel.applyForcingImmediately()
                })
                Text(String(format: "%.2f", viewModel.constantForce))
                    .font(.headline)
                    .foregroundColor(.primary)
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
