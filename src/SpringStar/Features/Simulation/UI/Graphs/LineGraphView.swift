//
//  LineGraphView.swift
//  SpringStar
//
//  Created by Seth & Jelly on 9/29/25.
//

import SwiftUI

enum GraphMetric {
    case displacement
    case velocity
    case acceleration
}

struct LineGraphView: View {

    let samples: [GraphSample]
    let metric: GraphMetric
    let playbackTime: Double
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Canvas { context, size in
                guard samples.count > 1 else { return }

                let values = samples.map(valueForMetric)
                guard
                    let minY = values.min(),
                    let maxY = values.max(),
                    maxY != minY
                else { return }

                let minX = samples.first!.time
                let maxX = samples.last!.time

                func x(_ t: Double) -> CGFloat {
                    CGFloat((t - minX) / (maxX - minX)) * size.width
                }

                func y(_ v: Double) -> CGFloat {
                    size.height - CGFloat((v - minY) / (maxY - minY)) * size.height
                }

                var path = Path()
                for (i, s) in samples.enumerated() {
                    let pt = CGPoint(x: x(s.time), y: y(valueForMetric(s)))
                    i == 0 ? path.move(to: pt) : path.addLine(to: pt)
                }

                context.stroke(path, with: .color(.accentColor), lineWidth: 2)

                // Playback cursor
                if playbackTime >= minX && playbackTime <= maxX {
                    let px = x(playbackTime)
                    var cursor = Path()
                    cursor.move(to: CGPoint(x: px, y: 0))
                    cursor.addLine(to: CGPoint(x: px, y: size.height))
                    context.stroke(cursor, with: .color(.red.opacity(0.7)), lineWidth: 1)
                }
            }
            .frame(height: 120)
        }
    }

    private func valueForMetric(_ s: GraphSample) -> Double {
        switch metric {
        case .displacement: return s.displacement
        case .velocity: return s.velocity
        case .acceleration: return s.acceleration
        }
    }
}
