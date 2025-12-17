//
//  CombinedLineGraphView.swift
//  SpringStar
//
//  Created by Jelly on 12/17/25.
// Assistance from Copilot

import SwiftUI

/// A combined plot that shows displacement and velocity on the same axes,
struct CombinedLineGraphView: View {
    @ObservedObject var graphStore: GraphDataStore
    let playbackTime: Double
    let title: String
    let showDisplacement: Bool
    let showVelocity: Bool
    //let showAcceleration: Bool

    private let displacementColor = Color.blue
    private let velocityColor = Color.orange
    // private let accelerationColor = Color.green

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .bold()
            /**
             This is the canvas we use to draw the graphs, I considered using ChartsUI here but for the animations Canvas seemed to be the ebtter option even though
             it was a bit more work
             */
            Canvas { context, size in
                let samples = graphStore.samples
                guard samples.count > 1 else { return }

                let times = samples.map { $0.time }
                let disp = samples.map { $0.displacement }
                let vel = samples.map { $0.velocity }
                // acceleration intentionally unimplemented atp scale focused on displacement & velocity
                // DEBUG: acceleration array available for uncommenting
                // let acc = samples.map { $0.acceleration }

                let minX = times.first ?? 0
                let maxX = times.last ?? 1

                // Compute y range from enabled series and add small padding
                var rawMinY = Double.greatestFiniteMagnitude
                var rawMaxY = -Double.greatestFiniteMagnitude
                if showDisplacement {
                    rawMinY = min(rawMinY, disp.min() ?? 0)
                    rawMaxY = max(rawMaxY, disp.max() ?? 0)
                }
                if showVelocity {
                    rawMinY = min(rawMinY, vel.min() ?? 0)
                    rawMaxY = max(rawMaxY, vel.max() ?? 0)
                }
                // not gna include acceleration in the y-range calculation bc it makes the scale for displacement horrible 
                // DEBUG: to include acceleration in the y-range, uncomment:
                /*
                if showAcceleration {
                    rawMinY = min(rawMinY, acc.min() ?? 0)
                    rawMaxY = max(rawMaxY, acc.max() ?? 0)
                }
                */
                if rawMinY == Double.greatestFiniteMagnitude {
                    rawMinY = 0
                    rawMaxY = 1
                }
                var minY = rawMinY
                var maxY = rawMaxY
                if minY == maxY {
                    minY -= 1
                    maxY += 1
                }
                // make symmetric around zero for nicer appearance
                let absMax = max(abs(minY), abs(maxY))
                minY = -absMax * 1.08
                maxY = absMax * 1.08

                func x(_ t: Double) -> CGFloat {
                    guard maxX != minX else { return 0 }
                    return CGFloat((t - minX) / (maxX - minX)) * size.width
                }

                func y(_ v: Double) -> CGFloat {
                    let frac = (v - minY) / (maxY - minY)
                    return size.height - CGFloat(frac) * size.height
                }

                // Draw grid w vertical and horizontal lines
                let gridColor = Color(.sRGBLinear, white: 0.85, opacity: 1)
                let yTickCount = 6
                let xTickCount = 10

                // Horizontal grid lines and Y tick labels
                for i in 0...yTickCount {
                    let yy = CGFloat(i) / CGFloat(yTickCount) * size.height
                    var p = Path()
                    p.move(to: CGPoint(x: 0, y: yy))
                    p.addLine(to: CGPoint(x: size.width, y: yy))
                    context.stroke(p, with: .color(gridColor), lineWidth: 1)

                    // Y tick value
                    let value = minY + Double(yTickCount - i) / Double(yTickCount) * (maxY - minY)
                    let label = String(format: "%.2f", value)
                    context.draw(Text(label).font(.caption2).foregroundColor(.secondary), at: CGPoint(x: 4, y: yy - 8))
                }

                // Vertical grid lines and X tick labels
                for i in 0...xTickCount {
                    let xx = CGFloat(i) / CGFloat(xTickCount) * size.width
                    var p = Path()
                    p.move(to: CGPoint(x: xx, y: 0))
                    p.addLine(to: CGPoint(x: xx, y: size.height))
                    context.stroke(p, with: .color(gridColor), lineWidth: 1)

                    // X tick value
                    let t = minX + Double(i) / Double(xTickCount) * (maxX - minX)
                    let label = String(format: "%.1f", t)
                    context.draw(Text(label).font(.caption2).foregroundColor(.secondary), at: CGPoint(x: xx, y: size.height - 10))
                }

                // Path for displacement
                if showDisplacement {
                    var dispPath = Path()
                    for (i, s) in samples.enumerated() {
                        let pt = CGPoint(x: x(s.time), y: y(s.displacement))
                        i == 0 ? dispPath.move(to: pt) : dispPath.addLine(to: pt)
                    }
                    context.stroke(dispPath, with: .color(displacementColor), lineWidth: 2)
                }

                // Path for velocity
                if showVelocity {
                    var velPath = Path()
                    for (i, s) in samples.enumerated() {
                        let pt = CGPoint(x: x(s.time), y: y(s.velocity))
                        i == 0 ? velPath.move(to: pt) : velPath.addLine(to: pt)
                    }
                    context.stroke(velPath, with: .color(velocityColor), lineWidth: 2)
                }

                // acceleration series intentionally not drawn to keep scale focused
                // DEBUG: to draw acceleration for debugging, uncomment the block below
                /*
                if showAcceleration {
                    var accPath = Path()
                    for (i, s) in samples.enumerated() {
                        let pt = CGPoint(x: x(s.time), y: y(s.acceleration))
                        i == 0 ? accPath.move(to: pt) : accPath.addLine(to: pt)
                    }
                    context.stroke(accPath, with: .color(accelerationColor), lineWidth: 2)
                }
                */

                // Playback cursor
                if playbackTime >= minX && playbackTime <= maxX {
                    let px = x(playbackTime)
                    var cursor = Path()
                    cursor.move(to: CGPoint(x: px, y: 0))
                    cursor.addLine(to: CGPoint(x: px, y: size.height))
                    context.stroke(cursor, with: .color(.red.opacity(0.7)), lineWidth: 1)
                }
            }
            .frame(height: 220)

            // Axis labels and legend
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 12) {
                        if showDisplacement {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(displacementColor)
                                .frame(width: 22, height: 6)
                            Text("Displacement (x)")
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                        if showVelocity {
                            Spacer().frame(width: 12)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(velocityColor)
                                .frame(width: 22, height: 6)
                            Text("Velocity (v)")
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                        // acceleration legend intentionally omitted
                        // DEBUG: to show acceleration legend for debugging, uncomment:
                        /*
                        if showAcceleration {
                            Spacer().frame(width: 12)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(accelerationColor)
                                .frame(width: 22, height: 6)
                            Text("Acceleration (a)")
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                        */
                    }

                    HStack {
                        Text("Time (s)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Magnitude")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
