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

                    // Logo
                    Image("SpringStarLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .shadow(radius: 14)
                }


                // Title
                Text("Spring Star")
                    .font(.system(size: 64, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(radius: 12)

                // Start button
                Button(action: onStart) {
                    Text("Start")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 520)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(.ultraThinMaterial)

                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.18),
                                                Color.white.opacity(0.04)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )

                                RoundedRectangle(cornerRadius: 26, style: .continuous)
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
    }
}

private struct SpaceBackground: View {
    var body: some View {
        ZStack {
            // Deep purple gradient
            LinearGradient(
                colors: [
                    Color(red: 28/255, green: 15/255, blue: 78/255),
                    Color(red: 18/255, green: 10/255, blue: 55/255),
                    Color(red: 10/255, green: 6/255, blue: 35/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Soft nebula blobs
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 520, height: 520)
                .blur(radius: 26)
                .offset(x: -240, y: -140)

            Circle()
                .fill(Color.white.opacity(0.05))
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
    var body: some View {
        Canvas { context, size in
            // fixed star set so it doesn't "move" between frames
            var rng = SeededGenerator(seed: 1337)

            // tiny stars
            for _ in 0..<180 {
                let x = CGFloat.random(in: 0...size.width, using: &rng)
                let y = CGFloat.random(in: 0...size.height, using: &rng)
                let r = CGFloat.random(in: 0.8...1.8, using: &rng)
                let a = Double.random(in: 0.25...0.85, using: &rng)

                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                    with: .color(.white.opacity(a))
                )
            }

            // a few bigger “sparkle” stars
            for _ in 0..<18 {
                let x = CGFloat.random(in: 0...size.width, using: &rng)
                let y = CGFloat.random(in: 0...size.height, using: &rng)
                let s = CGFloat.random(in: 7...14, using: &rng)

                var p = Path()
                p.move(to: CGPoint(x: x, y: y - s))
                p.addLine(to: CGPoint(x: x, y: y + s))
                p.move(to: CGPoint(x: x - s, y: y))
                p.addLine(to: CGPoint(x: x + s, y: y))

                context.stroke(p, with: .color(.yellow.opacity(0.75)), lineWidth: 1)
            }
        }
    }
}

/// Deterministic RNG for stable star placement
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 0xdeadbeef : seed }

    mutating func next() -> UInt64 {
        // xorshift64*
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
