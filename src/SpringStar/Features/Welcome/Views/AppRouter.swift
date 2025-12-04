//
//  AppRouter.swift
//  SpringStar
//
//  Created by Ashworth, Jack on 11/6/25.
//
import SwiftUI

final class AppRouter: ObservableObject {
    static let shared = AppRouter(); private init() {}
    @Published var route: Route = .splash
    enum Route { case splash, simulation }
}

struct RootView: View {
    @ObservedObject var router = AppRouter.shared
    var body: some View {
        Group {
            switch router.route {
            case .splash: SplashStartView()
            case .simulation: SimulationView()
            }
        }
    }
}
