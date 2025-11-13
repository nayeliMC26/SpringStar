//
//  SimulationViewModel.swift
//  SpringStar
//
//  Created by Seth & Jelly on 9/29/25.
//

import Foundation
import Combine

/// View model for the spring–mass–damper simulation.
/// Acts as the bridge between the SwiftUI interface (Sidebar, PlaybackBar)
/// and the underlying RealityKit renderer or simulation logic.
/// Currently, it serves as a placeholder controller — the math engine is not yet implemented.
public final class SimulationViewModel: ObservableObject {

    // Suppresses applying presets when we auto-select a preset based on m,c,k changes
    private var suppressPresetApply: Bool = false

    // MARK: - Input Parameters (bound to UI controls)

    /// Mass of the object (m)
    @Published public var mass: Float
    /// Damping coefficient (c)
    @Published public var damping: Float
    /// Spring stiffness (k)
    @Published public var stiffness: Float
    /// Initial displacement from rest position (y₀)
    @Published public var initialDisplacement: Float
    /// Initial velocity (v₀)
    @Published public var initialVelocity: Float
    /// Whether the simulation is currently running or paused
    @Published public private(set) var isRunning: Bool

    // MARK: - Output / Derived State

    /// The current “height” of the simulated mass, used to update the visual spring.
    @Published public private(set) var height: Float

    // MARK: - UI State Flags

    /// Toggles for which graphs to display in the sidebar
    @Published public var showDisplacement: Bool = true
    @Published public var showVelocity: Bool = false
    @Published public var showAcceleration: Bool = false

    /// Selected damping preset type (under, over, etc.)
    @Published public var dampingPreset: DampingPreset = .under
    /// Type of external forcing applied (none, sinusoid, constant)
    @Published public var forcingType: ForcingType = .none

    /// Parameters for sinusoidal forcing
    @Published public var sinusoidAmplitude: Float = 0
    @Published public var sinusoidFrequencyHz: Float = 1

    /// Constant external force magnitude
    @Published public var constantForce: Float = 0

    /// Currently selected overall preset (affects m, c, k)
    @Published public var selectedPreset: PresetType = .none

    // MARK: - Renderer

    /// Handles 3D visualization of the spring/mass.
    /// The renderer is a shared object referenced by both the simulation and UI.
    public let renderer: ProcSpringRenderer

    /// Base (rest) spring length used for rendering and reset position.
    private let baseRestLength: Float = 0.5

    public init() {
        // Create a default spring renderer with geometric parameters.
        renderer = ProcSpringRenderer(radius: 0.08, coils: 10, tubeRadius: 0.004)

        // Default simulation parameters.
        mass = 1.0
        damping = 0.2
        stiffness = 15.0

        // Initial conditions (y₀, v₀)
        let y0: Float = 0.1
        let v0: Float = 0
        initialDisplacement = y0
        initialVelocity = v0

        // Derived display height for initial visual position.
        height = max(0.05, baseRestLength + y0)
        isRunning = false
    }

    /// Starts the simulation.
    /// (Currently just toggles state — no physics integration yet.)
    public func start() {
        guard !isRunning else { return }
        isRunning = true
    }

    /// Stops the simulation (pauses or halts motion).
    public func stop() {
        isRunning = false
    }

    /// Resets all parameters and state back to zero/defaults.
    /// Primarily used by the Reset button in the UI.
    public func reset() {
        isRunning = false
        mass = 0
        damping = 0
        stiffness = 0
        initialDisplacement = 0
        initialVelocity = 0
        selectedPreset = .none
        height = max(0.05, baseRestLength)
    }

    /// Applies new mass/damping/stiffness values immediately.
    /// Placeholder for future simulation updates.
    public func applyParamsImmediately() {
        // TODO: Integrate with physics solver once implemented.
        // Additionally, update preset selection based on current m, c, k.
        updatePresetSelectionFromParams()
    }

    /// Temporarily adjusts the displayed height based on the initial displacement
    /// if the simulation is idle (not running).
    public func previewInitialConditionsIfIdle() {
        guard !isRunning else { return }
        height = max(0.05, baseRestLength + initialDisplacement)
    }

    /// Applies forcing parameters (amplitude, frequency, constant force) immediately.
    /// Placeholder for future implementation.
    public func applyForcingImmediately() {
        // TODO: Send forcing update to physics calculator when available.
    }

    /// Updates selectedPreset based on current m, c, k values.
    /// If they exactly match a known preset's parameters, selects that preset; otherwise selects .none.
    private func updatePresetSelectionFromParams() {
        // Build the known presets using their default parameter values
        let over = Presets.overdamped()
        let crit = Presets.criticallyDamped()
        let under = Presets.underdamped()
        let undamped = Presets.undamped()

        func matches(_ p: Preset) -> Bool {
            return self.mass == p.params.mass && self.damping == p.params.damping && self.stiffness == p.params.stiffness
        }

        let newSelection: PresetType
        if matches(over) { newSelection = .over }
        else if matches(crit) { newSelection = .crit }
        else if matches(under) { newSelection = .under }
        else if matches(undamped) { newSelection = .undamped }
        else { newSelection = .none }

        // Only update if different to avoid needless churn
        if newSelection != selectedPreset {
            suppressPresetApply = true
            selectedPreset = newSelection
            // Clear suppression on the next runloop to avoid triggering applySelectedPreset
            DispatchQueue.main.async { [weak self] in
                self?.suppressPresetApply = false
            }
        }
    }

    /// High-level damping behavior categories
    public enum DampingPreset: String, CaseIterable, Identifiable {
        case over, under, crit, undamped
        public var id: String { rawValue }
    }

    /// External force types that can be applied to the system
    public enum ForcingType: String, CaseIterable, Identifiable {
        case none, sinusoid, constant
        public var id: String { rawValue }
    }

    /// Combined preset type (used by sidebar for convenience)
    public enum PresetType: String, CaseIterable, Identifiable {
        case none, over, crit, under, undamped
        public var id: String { rawValue }
    }

    /// Applies a damping preset (overdamped, underdamped, etc.)
    /// by computing damping based on the critical damping coefficient.
    public func setDampingPreset(_ preset: DampingPreset) {
        dampingPreset = preset

        // Compute critical damping value: c_crit = 2 * sqrt(m * k)
        let m = max(mass, 1e-6) // avoid divide-by-zero
        let k = max(stiffness, 0)
        let cCrit = 2 * sqrt(m * k)

        switch preset {
        case .undamped:
            damping = 0
        case .under:
            damping = 0.2 * cCrit
        case .crit:
            damping = cCrit
        case .over:
            damping = 1.5 * cCrit
        }

        // Update simulation with new damping (UI only for now)
        applyParamsImmediately()
    }

    /// Returns a forcing object representing the current user selection.
    /// Used to configure how the system is driven (sinusoidal, constant, etc.).
    private func controllerForcing() -> Forcing {
        switch forcingType {
        case .none:
            return .none
        case .sinusoid:
            return .sinusoid(
                amplitude: sinusoidAmplitude,
                frequencyHz: sinusoidFrequencyHz,
                phase: 0
            )
        case .constant:
            return .constant(constantForce)
        }
    }

    // MARK: - Preset Handling

    /// Applies one of the predefined system presets.
    /// Each preset defines m, c, k, and initial conditions.
    public func applySelectedPreset() {
        // If we are programmatically setting the preset based on slider changes,
        // do not re-apply the preset values (which would overwrite user input).
        if suppressPresetApply { return }
        switch selectedPreset {
        case .none:
            return
        case .over:
            applyPreset(Presets.overdamped())
        case .crit:
            let p = Presets.criticallyDamped()
            applyPreset(p)
        case .under:
            let p = Presets.underdamped()
            applyPreset(p)
        case .undamped:
            let p = Presets.undamped()
            applyPreset(p)
        }
    }

    /// Assigns parameters from a specific preset to the current model.
    private func applyPreset(_ preset: Preset) {
        mass = preset.params.mass
        damping = preset.params.damping
        stiffness = preset.params.stiffness
        initialDisplacement = preset.y0
        initialVelocity = preset.v0

        // Update visual preview (spring height) for user feedback.
        height = max(0.05, preset.params.restLength + preset.y0)
    }
}
