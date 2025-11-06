//
//  SplashStartView.swift
//  SpringStar
//
//  Created by Ashworth, Jack on 11/6/25.
//

import SwiftUI

struct SplashStartView: View {
    @State private var isReady = false
    @State private var showTapHint = false
     private let minimumDisplayTime: TimeInterval = 1.5
    
    var body: some View{
        ZStack {
            StarField()
                .ignoresSafeArea()
            
            VStack(spacing: 24){
                Image("springstar_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(radius: 20)
                    .overlay(
                        Group {
                            if UIImage(named: "springstar_logo") == nil {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 84, weight: .ultraLight))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                        }
                    )
                    .accessibilityLabel("SpringStar Logo")
                
                if !isReady {
                    ProgressView("Initializing Simulation...")
                        .tint(.white)
                        .foregroundStyle(.white.opacity(showTapHint ? 1 : 0.35))
                        .animation(.easeInOut(duration: 1).repeatForever(), value: showTapHint)
                }
            }
            .padding(40)
        }
        .task{
            try? await Task.sleep(nanoseconds: UInt64(minimumDisplayTime * 1_000_000_000))
            isReady = true
            showTapHint = true
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard isReady else {return}
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)){
                AppRouter.shared.route = .simulation
            }
        }
    }
}
