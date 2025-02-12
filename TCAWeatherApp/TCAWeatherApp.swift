//
//  TCAWeatherApp.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import SwiftUI
import UIKit

@main
struct TCAWeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: WeatherViewModel(weather: previewData))
        }
    }
}
