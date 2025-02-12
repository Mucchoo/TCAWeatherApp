//
//  ContentView.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import SwiftUI
import CoreLocation
import CoreLocationUI
import WeatherKit

struct ContentView: View {
    @StateObject var viewModel: WeatherViewModel
    var weatherManager = WeatheryManager()
    @State var weather: ResponseData?
    
    var body: some View {
        VStack {
            MainView(weather: weather ?? viewModel.weather, viewModel: viewModel)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    ContentView(viewModel: WeatherViewModel(weather: previewData))
}
