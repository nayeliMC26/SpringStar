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
                
                // Draw grid and ticks
                let gridColor = Color(.sRGBLinear, white: 0.9, opacity: 1)

                // Number of tick marks on each axis
                let yTickCount = 4
                let xTickCount = 6

                // --- Y-axis grid lines and labels ---
                for i in 0...yTickCount {
                    // Compute the y-position of this gridline (evenly spaced vertically)
                    let yy = CGFloat(i) / CGFloat(yTickCount) * size.height
                    
                    // Draw horizontal grid line
                    var p = Path()
                    p.move(to: CGPoint(x: 0, y: yy))
                    p.addLine(to: CGPoint(x: size.width, y: yy))
                    context.stroke(p, with: .color(gridColor), lineWidth: 1)

                    // Compute the corresponding value for the y-axis label
                    // (reverse order so maxY appears at top)
                    let value = minY + Double(yTickCount - i) / Double(yTickCount) * (maxY - minY)
                    let label = String(format: "%.2f", value)
                    
                    // Draw the y-axis label slightly above the grid line
                    context.draw(
                        Text(label).font(.caption2).foregroundColor(.secondary),
                        at: CGPoint(x: 4, y: yy - 8)
                    )
                }

                // --- X-axis grid lines and labels ---
                for i in 0...xTickCount {
                    // Compute the x-position of this gridline (evenly spaced horizontally)
                    let xx = CGFloat(i) / CGFloat(xTickCount) * size.width
                    
                    // Draw vertical grid line
                    var p = Path()
                    p.move(to: CGPoint(x: xx, y: 0))
                    p.addLine(to: CGPoint(x: xx, y: size.height))
                    context.stroke(p, with: .color(gridColor), lineWidth: 1)

                    // Compute the corresponding value for the x-axis label
                    let t = minX + Double(i) / Double(xTickCount) * (maxX - minX)
                    let label = String(format: "%.1f", t)
                    
                    // Draw the x-axis label near the bottom
                    context.draw(
                        Text(label).font(.caption2).foregroundColor(.secondary),
                        at: CGPoint(x: xx, y: size.height - 10)
                    )
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
