//
//  StarField.swift
//  SpringStar
//
//  Created by Ashworth, Jack on 11/6/25.
//

import SwiftUI

struct StarField: View {
    var starCount: Int = 240

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                // Deterministic RNG for stable star positions
                var generator = RandomNumberGeneratorWithSeed(seed: 42)

                var stars: [Star] = []
                stars.reserveCapacity(starCount)
                for _ in 0..<starCount {
                    let x = Double.random(in: 0...size.width, using: &generator)
                    let y = Double.random(in: 0...size.height, using: &generator)
                    let speed = Double.random(in: 6...28, using: &generator)
                    let radius = Double.random(in: 0.5...1.8, using: &generator)
                    let twinkle = Double.random(in: 0.5...1.0, using: &generator)
                    stars.append(Star(origin: CGPoint(x: x, y: y),
                                      speed: speed, radius: radius, twinkle: twinkle))
                }

                // Background gradient
                let rect = CGRect(origin: .zero, size: size)
                context.fill(
                    Path(rect),
                    with: .linearGradient(
                        Gradient(colors: [.black, Color.blue.opacity(0.25), .black]),
                        startPoint: CGPoint(x: rect.midX, y: rect.minY),
                        endPoint:   CGPoint(x: rect.midX, y: rect.maxY)
                    )
                )

                // Animate downward drift & twinkle
                for star in stars {
                    let y = (star.origin.y
                             + star.speed * now.truncatingRemainder(dividingBy: 100))
                        .truncatingRemainder(dividingBy: size.height)

                    let point = CGPoint(x: star.origin.x, y: y)
                    var glyph = context.resolve(Text("•").font(.system(size: star.radius * 3)))

                    let alpha = 0.6 + 0.4 * sin(now * star.twinkle + star.origin.x / 50)
                    glyph.shading = .color(.white.opacity(alpha))
                    context.draw(glyph, at: point)
                }
            }
        }
    }
}


private struct Star {
    let origin: CGPoint
    let speed: Double
    let radius: Double
    let twinkle: Double
}

/// Deterministic RNG so star field is stable frame-to-frame
private struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E_37_79_B9_7F_4A_7C_15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF_58_47_6D_1C_E4_E5_B9
        z = (z ^ (z >> 27)) &* 0x94_D0_49_BB_13_31_11_EB
        return z ^ (z >> 31)
    }

}
