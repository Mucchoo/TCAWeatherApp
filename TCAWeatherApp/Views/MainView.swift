//
//  MainView.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import SwiftUI

struct MainView: View {
    @State var weather: ResponseData
    @StateObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    WeatherView(weather: weather, viewModel: viewModel)
                }
            }
            .background(Color(.systemBackground).opacity(0.8))
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        }
    }
}
    
#Preview {
    MainView(weather: previewData, viewModel: WeatherViewModel(weather: previewData))
}
