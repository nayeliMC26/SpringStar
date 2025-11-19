//
//  LineGraphView.swift
//  SpringStar
//
//  Created by Seth & Jelly on 9/29/25.
//

import SwiftUI

struct LineGraphView: View {
    struct Series: Identifiable {
        let id = UUID()
        let name: String
        let values: [Double]
    }

    let seconds: [Double]
    let series: [Series]
    var height: CGFloat = 160
    var cursor01: Double? = nil     // <<--- ADD THIS

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)

            // Draw border
            var border = Path()
            border.addRect(rect)
            context.stroke(border, with: .color(.white.opacity(0.12)), lineWidth: 1)

            guard let tMin = seconds.first,
                  let tMax = seconds.last,
                  tMax > tMin else { return }

            // Grid lines
            for i in 1..<5 {
                let y = rect.minY + rect.height * CGFloat(Double(i) / 5)
                var p = Path()
                p.move(to: CGPoint(x: rect.minX, y: y))
                p.addLine(to: CGPoint(x: rect.maxX, y: y))
                context.stroke(p, with: .color(.white.opacity(0.08)))
            }

            // Draw series
            for (idx, s) in series.enumerated() {
                guard s.values.count == seconds.count else { continue }

                let vMin = s.values.min() ?? -1
                let vMax = s.values.max() ?? 1
                let span = max(1e-6, vMax - vMin)

                var p = Path()
                for i in s.values.indices {
                    let t = seconds[i]
                    let v = s.values[i]

                    let x = rect.minX + rect.width * CGFloat((t - tMin) / (tMax - tMin))
                    let yNorm = (v - vMin) / span
                    let y = rect.maxY - rect.height * CGFloat(yNorm)

                    let pt = CGPoint(x: x, y: y)
                    if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                }

                let colors: [Color] = [.mint, .cyan, .orange, .pink]
                context.stroke(p, with: .color(colors[idx % colors.count]), lineWidth: 1.6)
            }

            // Cursor line (playback indicator)
            if let c = cursor01 {
                let x = rect.minX + rect.width * CGFloat(min(max(c, 0), 1))
                var path = Path()
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.maxY))
                context.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 1)
            }
        }
        .frame(height: height)
        .background(.black.opacity(0.25),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}


