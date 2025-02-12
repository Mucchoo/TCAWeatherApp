//
//  WeatherView.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import SwiftUI
import Combine

struct WeatherView: View {
    var weather: ResponseData
    @StateObject var viewModel: WeatherViewModel
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    TopWeatherView(viewModel: viewModel)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.weather.list, id: \.self) { hourly in
                                HourlyForecastView(weatherList: hourly, weather: viewModel.weather, viewModel: viewModel)
                            }
                        }
                    }
                    
                    SunriseView(viewModel: viewModel)
                                        
                    let sortedDailyForecasts = viewModel.dailyForecasts.sorted { $0.day < $1.day }
                    
                    VStack(alignment: .leading) {
                        ForEach(sortedDailyForecasts, id: \.day) { daily in
                            DailyForecastView(dailyForecast: daily, viewModel: viewModel)
                        }
                    }
                    .background(Color.white)
                    .foregroundColor(.primary)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
                .padding()
                .aspectRatio(1.0, contentMode: .fill)
                .onAppear {
                    viewModel.getWeatherForecast()
                }
            }
        }
        .background(Color(.systemBackground).opacity(0.8))
    }
}

#Preview {
    WeatherView(weather: previewData, viewModel: WeatherViewModel(weather: previewData))
}


