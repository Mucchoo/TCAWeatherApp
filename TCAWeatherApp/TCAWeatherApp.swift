//
//  TCAWeatherApp.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCAWeatherApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherView(
                store: Store(
                    initialState: WeatherFeature.State(),
                    reducer: { WeatherFeature() }
                )
            )
        }
    }
}
