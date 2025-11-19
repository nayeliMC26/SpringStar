//
//  SimulationViewModel.swift
//  SpringStar
//
//  Created by Seth & Jelly on 9/29/25.
//

import Foundation
import Combine
import SwiftUI

public final class SimulationViewModel: ObservableObject {
    // MARK: Inputs bound to the sidebar
    @Published public var mass: Float
    @Published public var damping: Float
    @Published public var stiffness: Float
    @Published public var initialDisplacement: Float
    @Published public var initialVelocity: Float
    @Published public private(set) var isRunning: Bool

    // Graph toggles
    @Published public var showDisplacement: Bool = true
    @Published public var showVelocity: Bool = false
    @Published public var showAcceleration: Bool = false

    // Presets / forcing
    @Published public var dampingPreset: DampingPreset = .under
    @Published public var forcingType: ForcingType = .none
    @Published public var sinusoidAmplitude: Float = 0
    @Published public var sinusoidFrequencyHz: Float = 1
    @Published public var constantForce: Float = 0
    @Published public var selectedPreset: PresetType = .none

    // Renderer
    public let renderer: ProcSpringRenderer
    private let baseRestLength: Float = 0.5
    @Published public private(set) var height: Float

    // MARK: Graph data (dummy engine)
    @Published public private(set) var timeSeries: [Double] = []
    @Published public private(set) var displacementSeries: [Double] = []
    @Published public private(set) var velocitySeries: [Double] = []
    @Published public private(set) var accelerationSeries: [Double] = []

    // Playback
    @Published public var playbackProgress: Double = 0   // 0...1 slider
    @Published public private(set) var elapsedLabel: String = "00:00"

    private let graphs = GraphDataStore()
    private var bag = Set<AnyCancellable>()

    public init() {
        renderer = ProcSpringRenderer(radius: 0.08, coils: 10, tubeRadius: 0.004)

        mass = 1.0; damping = 0.2; stiffness = 15.0
        initialDisplacement = 0.1; initialVelocity = 0
        height = max(0.5, baseRestLength + 0.1)
        isRunning = false

        // Pipe GraphDataStore → published arrays
        graphs.$time
            .receive(on: RunLoop.main)
            .assign(to: &$timeSeries)
        graphs.$y
            .receive(on: RunLoop.main)
            .assign(to: &$displacementSeries)
        graphs.$v
            .receive(on: RunLoop.main)
            .assign(to: &$velocitySeries)
        graphs.$a
            .receive(on: RunLoop.main)
            .assign(to: &$accelerationSeries)

        graphs.$progress
            .receive(on: RunLoop.main)
            .assign(to: &$playbackProgress)

        graphs.$elapsed
            .map { t -> String in
                let mm = Int(t) / 60
                let ss = Int(t) % 60
                return String(format: "%02d:%02d", mm, ss)
            }
            .receive(on: RunLoop.main)
            .assign(to: &$elapsedLabel)

        // Keep the preview height in sync when idle
        $initialDisplacement
            .sink { [weak self] _ in self?.previewInitialConditionsIfIdle() }
            .store(in: &bag)
    }

    // MARK: Public controls
    public func start() {
        guard !isRunning else { return }
        isRunning = true
        graphs.updateParams(currentParams())
        graphs.start()
    }

    public func stop() {
        isRunning = false
        graphs.stop()
    }

    public func reset() {
        stop()
        // Feel nicer than zeroing everything; set reasonable defaults
        mass = 1.0; damping = 0.2; stiffness = 15.0
        initialDisplacement = 0.1; initialVelocity = 0
        selectedPreset = .none
        height = max(0.05, baseRestLength + initialDisplacement)
        graphs.reset()
    }
    
    public func rewind(seconds: Float){
        //No data, nothing to rewind
        guard !timeSeries.isEmpty else { return }
        
        //ask graph engine to rewind
        graphs.rewind(seconds: Double(seconds))
        
        //use last displacement for spring height 
        if let lastY = displacementSeries.last {
            height = max(0.05, baseRestLength + Float(lastY))
        }
    }
    
    public func applyParamsImmediately() {
        graphs.updateParams(currentParams())
    }

    public func previewInitialConditionsIfIdle() {
        guard !isRunning else { return }
        height = max(0.05, baseRestLength + initialDisplacement)
    }

    public func applyForcingImmediately() {
        graphs.updateParams(currentParams())
    }

    // MARK: Presets / enums
    public enum DampingPreset: String, CaseIterable, Identifiable { case over, under, crit, undamped; public var id: String { rawValue } }
    public enum ForcingType: String, CaseIterable, Identifiable { case none, sinusoid, constant; public var id: String { rawValue } }
    public enum PresetType: String, CaseIterable, Identifiable { case none, over, crit, under, undamped; public var id: String { rawValue } }

    public func setDampingPreset(_ preset: DampingPreset) {
        dampingPreset = preset
        let m = max(Double(mass), 1e-6), k = max(Double(stiffness), 0)
        let cCrit = 2 * sqrt(m * k)
        switch preset {
        case .undamped: damping = 0
        case .under:    damping = Float(0.2 * cCrit)
        case .crit:     damping = Float(cCrit)
        case .over:     damping = Float(1.5 * cCrit)
        }
        applyParamsImmediately()
    }

    public func applySelectedPreset() {
        switch selectedPreset {
        case .none: return
        case .over:
            mass = 1.2; stiffness = 12; setDampingPreset(.over)
        case .crit:
            mass = 1.0; stiffness = 16; setDampingPreset(.crit)
        case .under:
            mass = 1.0; stiffness = 18; setDampingPreset(.under)
        case .undamped:
            mass = 1.0; stiffness = 18; setDampingPreset(.undamped)
        }
        initialDisplacement = 0.1
        initialVelocity = 0
        height = max(0.05, baseRestLength + initialDisplacement)
        applyParamsImmediately()
    }

    // MARK: Helpers
    private func currentParams() -> GraphDataStore.Params {
        let forcing: GraphDataStore.Params.Forcing
        switch forcingType {
        case .none:
            forcing = .none
        case .sinusoid:
            forcing = .sinusoid(A: Double(sinusoidAmplitude), fHz: Double(sinusoidFrequencyHz))
        case .constant:
            forcing = .constant(Double(constantForce))
        }
        return .init(
            m: Double(mass),
            c: Double(damping),
            k: Double(stiffness),
            y0: Double(initialDisplacement),
            v0: Double(initialVelocity),
            forcing: forcing
        )
    }
}
