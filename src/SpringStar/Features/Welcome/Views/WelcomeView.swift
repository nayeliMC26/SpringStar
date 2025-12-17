//
//  WelcomeView.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.
//

import SwiftUI

struct WelcomeView: View {
    var onStart: () -> Void

    var body: some View {
        ZStack {
            SpaceBackground()
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 30)

                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.blue.opacity(0.35),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 140
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 10)

                    // Glass ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.45),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 240, height: 240)

                    // Inner glass circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 220, height: 220)
                        .overlay(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.18),
                                            Color.white.opacity(0.02)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )

                    // Logo built from three stacked logo artboards (back, middle, front)
                    ZStack {
                        Image("Artboard 1@2x")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 220)
                            .scaleEffect(1.00)
                            .opacity(0.95)
                            .clipShape(Circle())
                            .clipped()

                        Image("MiddleArtboard 1@2x")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .scaleEffect(1.00)
                            .opacity(0.98)

                        Image("FrontArtboard 1@2x")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .scaleEffect(1.04)
                            .shadow(radius: 14)
                    }
                }

                let title = "Spring Star"
                let titleFont = Font.system(
                    size: 64,
                    weight: .heavy,
                    design: .rounded
                )

                Text(title.uppercased())
                    .font(titleFont)
                    .tracking(6)  // logo feel
                    .foregroundColor(.clear)

                    // Glow
                    .background(
                        LinearGradient(
                            colors: [
                                Color(
                                    red: 254 / 255,
                                    green: 203 / 255,
                                    blue: 69 / 255
                                ).opacity(0.95),
                                Color(
                                    red: 255 / 255,
                                    green: 240 / 255,
                                    blue: 150 / 255
                                ).opacity(0.75),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(
                            Text(title.uppercased())
                                .font(titleFont)
                                .tracking(6)
                        )
                        .blur(radius: 4)
                        .opacity(0.55)
                    )

                    // Main color gradinet
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color(
                                    red: 252 / 255,
                                    green: 243 / 255,
                                    blue: 69 / 255
                                ),
                                Color(
                                    red: 255 / 255,
                                    green: 245 / 255,
                                    blue: 160 / 255
                                ),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text(title.uppercased())
                                .font(titleFont)
                                .tracking(6)
                        )
                    )

                    // Highlight
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(
                            Text(title.uppercased())
                                .font(titleFont)
                                .tracking(6)
                        )
                        .blendMode(.overlay)
                        .opacity(0.20)
                    )

                    // Inner shadow
                    .overlay(
                        Text(title.uppercased())
                            .font(titleFont)
                            .tracking(6)
                            .foregroundColor(.black.opacity(0.15))
                            .offset(x: 1, y: 1)
                            .blur(radius: 1)
                    )

                    .shadow(
                        color: Color(
                            red: 6 / 255,
                            green: 10 / 255,
                            blue: 32 / 255
                        ).opacity(0.65),
                        radius: 12,
                        x: 0,
                        y: 6
                    )

                // Start button
                Button(action: onStart) {
                    Text("Start")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 520)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                RoundedRectangle(
                                    cornerRadius: 26,
                                    style: .continuous
                                )
                                .fill(.ultraThinMaterial)

                                RoundedRectangle(
                                    cornerRadius: 26,
                                    style: .continuous
                                )
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.18),
                                            Color.white.opacity(0.04),
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                                RoundedRectangle(
                                    cornerRadius: 26,
                                    style: .continuous
                                )
                                .stroke(Color.white.opacity(0.22), lineWidth: 1)
                            }
                        )
                        .shadow(radius: 16)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .clipShape(RoundedRectangle(cornerRadius: 90, style: .continuous))
        .padding(.all, 8)
    }
}

private struct SpaceBackground: View {
    var body: some View {
        ZStack {
            // Deep indigo-blueish gradient
            LinearGradient(
                colors: [
                    Color(red: 6 / 255, green: 12 / 255, blue: 60 / 255),
                    Color(red: 18 / 255, green: 30 / 255, blue: 120 / 255),
                    Color(red: 6 / 255, green: 10 / 255, blue: 32 / 255),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Soft nebula blobs
            Circle()
                .fill(
                    Color(red: 100 / 255, green: 140 / 255, blue: 255 / 255)
                        .opacity(0.06)
                )
                .frame(width: 520, height: 520)
                .blur(radius: 26)
                .offset(x: -240, y: -140)

            Circle()
                .fill(
                    Color(red: 80 / 255, green: 120 / 255, blue: 220 / 255)
                        .opacity(0.05)
                )
                .frame(width: 420, height: 420)
                .blur(radius: 30)
                .offset(x: 240, y: 120)

            // Stars
            StarField()
                .opacity(0.9)
        }
    }
}

private struct StarField: View {
    private struct Star {
        var x: CGFloat
        var y: CGFloat
        var radius: CGFloat
        var baseAlpha: Double
        var saturation: Double
        var phase: Double
        var speed: Double
        var isLarge: Bool
        /// 0 = small dot, 1 = medium star, 2 = large star
        var sizeCategory: Int
    }

    @State private var stars: [Star] = StarField.generateStars()

    private static func generateStars() -> [Star] {
        var rng = SeededGenerator(seed: 1337)
        var out: [Star] = []

        // many tiny stars (mostly white-ish)
        for _ in 0..<220 {
            let x = CGFloat.random(in: 0...1, using: &rng)
            let y = CGFloat.random(in: 0...1, using: &rng)
            let r = CGFloat.random(in: 0.3...0.9, using: &rng)
            let a = Double.random(in: 0.25...0.9, using: &rng)
            let sat = Double.random(in: 0.0...0.35, using: &rng)
            let phase = Double.random(in: 0...(.pi * 2), using: &rng)
            let speed = Double.random(in: 0.8...2.4, using: &rng)
            out.append(
                Star(
                    x: x,
                    y: y,
                    radius: r,
                    baseAlpha: a,
                    saturation: sat,
                    phase: phase,
                    speed: speed,
                    isLarge: false,
                    sizeCategory: 0
                )
            )
        }

        // medium stars
        for _ in 0..<90 {
            let x = CGFloat.random(in: 0...1, using: &rng)
            let y = CGFloat.random(in: 0...1, using: &rng)
            let r = CGFloat.random(in: 3.0...6.0, using: &rng)
            let a = Double.random(in: 0.5...1.0, using: &rng)
            let sat = Double.random(in: 0.18...0.65, using: &rng)
            let phase = Double.random(in: 0...(.pi * 2), using: &rng)
            let speed = Double.random(in: 0.5...1.6, using: &rng)
            out.append(
                Star(
                    x: x,
                    y: y,
                    radius: r,
                    baseAlpha: a,
                    saturation: sat,
                    phase: phase,
                    speed: speed,
                    isLarge: false,
                    sizeCategory: 1
                )
            )
        }

        // larger colored stars
        for _ in 0..<45 {
            let x = CGFloat.random(in: 0...1, using: &rng)
            let y = CGFloat.random(in: 0...1, using: &rng)
            let r = CGFloat.random(in: 6...12, using: &rng)
            let a = Double.random(in: 0.7...1.0, using: &rng)
            let sat = Double.random(in: 0.45...0.98, using: &rng)
            let phase = Double.random(in: 0...(.pi * 2), using: &rng)
            let speed = Double.random(in: 0.4...1.6, using: &rng)
            out.append(
                Star(
                    x: x,
                    y: y,
                    radius: r,
                    baseAlpha: a,
                    saturation: sat,
                    phase: phase,
                    speed: speed,
                    isLarge: true,
                    sizeCategory: 2
                )
            )
        }

        return out
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for s in stars {
                    // base position in pixels
                    let baseX = s.x * size.width
                    let baseY = s.y * size.height

                    // drift motion
                    let driftAmp: Double
                    switch s.sizeCategory {
                    case 2: driftAmp = 14.0
                    case 1: driftAmp = 8.0
                    default: driftAmp = 2.0
                    }
                    let driftX =
                        CGFloat(driftAmp)
                        * CGFloat(sin(t * s.speed * 0.25 + s.phase))
                    let driftY =
                        CGFloat(driftAmp)
                        * CGFloat(cos(t * s.speed * 0.25 + s.phase * 1.3))

                    let cx = baseX + driftX
                    let cy = baseY + driftY

                    // twinkle factor
                    let tw = 0.5 + 0.5 * sin(t * s.speed + s.phase)
                    let alpha = min(1.0, s.baseAlpha * (0.6 + 0.8 * tw))

                    let hue: Double = 0.13
                    let color = Color(
                        hue: hue,
                        saturation: s.saturation,
                        brightness: 0.8
                    ).opacity(alpha)

                    if s.sizeCategory == 0 {
                        let rect = CGRect(
                            x: cx - s.radius / 2,
                            y: cy - s.radius / 2,
                            width: s.radius,
                            height: s.radius
                        )
                        context.fill(Path(ellipseIn: rect), with: .color(color))
                    } else {
                        let inner = s.radius * 0.65
                        let path = starPath(
                            center: CGPoint(x: cx, y: cy),
                            outerRadius: s.radius,
                            innerRadius: inner,
                            points: 5
                        )
                        context.fill(path, with: .color(color))
                    }
                }
            }
        }
    }
}

// Helper to build a star Path
private func starPath(
    center: CGPoint,
    outerRadius: CGFloat,
    innerRadius: CGFloat,
    points: Int
) -> Path {
    var path = Path()
    let angle = .pi * 2 / CGFloat(points * 2)
    let start = -CGFloat.pi / 2
    for i in 0..<(points * 2) {
        let radius = (i % 2 == 0) ? outerRadius : innerRadius
        let x = center.x + cos(start + CGFloat(i) * angle) * radius
        let y = center.y + sin(start + CGFloat(i) * angle) * radius
        if i == 0 {
            path.move(to: CGPoint(x: x, y: y))
        } else {
            path.addLine(to: CGPoint(x: x, y: y))
        }
    }
    path.closeSubpath()
    return path
}

/// Deterministic RNG for stable star placement
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 0xdead_beef : seed }

    mutating func next() -> UInt64 {
        // xorshift64*
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
