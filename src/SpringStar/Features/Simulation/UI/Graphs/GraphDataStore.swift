//
//  GraphDataStore.swift
//  SpringStar
//
//  Created by Seth & Jelly on 9/29/25.
//

import Foundation

struct GraphSample: Identifiable {
    let id = UUID()
    let time: Double
    let displacement: Double
    let velocity: Double
    let acceleration: Double
}

final class GraphDataStore: ObservableObject {

    @Published private(set) var samples: [GraphSample] = []

    /// Max history length (seconds)
    private let maxDuration: Double = 120.0

    func append(
        time: Double,
        displacement: Double,
        velocity: Double,
        acceleration: Double
    ) {
        samples.append(
            GraphSample(
                time: time,
                displacement: displacement,
                velocity: velocity,
                acceleration: acceleration
            )
        )
        trim()
    }

    private func trim() {
        guard let latest = samples.last else { return }
        let cutoff = latest.time - maxDuration
        samples.removeAll { $0.time < cutoff }
    }

    func sample(at time: Double) -> GraphSample? {
        samples.min(by: { abs($0.time - time) < abs($1.time - time) })
    }

    var maxTime: Double {
        samples.last?.time ?? 0
    }

    func reset() {
        samples.removeAll()
    }
}

