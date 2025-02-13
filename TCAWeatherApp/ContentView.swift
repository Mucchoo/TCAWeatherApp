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
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            if let weather = viewModel.weatherState {
                ScrollView(showsIndicators: false) {
                    scrollViewContent(weather: weather)
                    .padding()
                    .aspectRatio(1.0, contentMode: .fill)
                }
            } else if viewModel.isLoading {
                ProgressView()
                     .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                     .font(.system(size: 100))
            } else {
                VStack {
                    Text("Please share your current location to get the weather in your area")
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    
                    LocationButton(.shareCurrentLocation) {
                        Task { await viewModel.getWeatherData() }
                    }
                    .cornerRadius(30)
                    .symbolVariant(.fill)
                    .foregroundColor(.white)
                    .background(Color(.systemBackground))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemBackground).opacity(0.8))
    }
    
    private func scrollViewContent(weather: WeatherViewModel.State) -> some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(formatedTime(time: Date.now, timeZoneOffset: weather.timezone))
                        .font(.caption2)
                        .bold()
                    Text(weather.temperature)
                        .font(.system(size: 40))
                    Text(weather.name)
                        .font(.body)
                        .bold()
                }
                Spacer()
                viewModel.weatherIcon(for: weather.main)
                    .renderingMode(.original)
                    .font(.system(size: 50))
                    .shadow(radius: 5)
            }
            .padding()
            .background(Color.white)
            .foregroundColor(.primary)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            
            sunriseView(weather)
            dailyForecastsView(weather)
        }
    }
    
    private func sunriseView(_ weather: WeatherViewModel.State) -> some View {
        HStack {
            Text("Sunrise")
                .bold()
            Image(systemName: "sun.max.fill")
                .renderingMode(.original)
            Text(formatTime(unixTime: weather.sunrise, timeZoneOffset: weather.timezone))
            Spacer()
            Text("Sunset")
                .bold()
            Image(systemName: "moon.fill")
                .foregroundColor(Color("DarkBlue"))
            Text(formatTime(unixTime: weather.sunset, timeZoneOffset: weather.timezone))
        }
        .font(.body)
        .padding()
        .background(Color.white)
        .foregroundColor(.primary)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    private func dailyForecastsView(_ weather: WeatherViewModel.State) -> some View {
        let sortedDailyForecasts = weather.dailyForecasts.sorted { $0.day < $1.day }
        
        return VStack(alignment: .leading) {
            ForEach(sortedDailyForecasts, id: \.day) { dailyForecast in
                HStack {
                    HStack {
                        Text(viewModel.formattedTime(from: dailyForecast.day, timeZoneOffset: weather.timezone) ?? "")
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        viewModel.weatherIcon(for: dailyForecast.main)
                            .renderingMode(.original)
                            .shadow(radius: 5)
                        Text(dailyForecast.main)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(String(format: "%.0f", dailyForecast.maxTemp.tempToCelsius()))°")
                        Text("\(String(format: "%.0f", dailyForecast.minTemp.tempToCelsius()))°")
                        Spacer()
                    }
                    .bold()
                    
                }
                .padding()
            }
        }
        .background(Color.white)
        .foregroundColor(.primary)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    func formatedTime(time: Date, timeZoneOffset: Double) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E, HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
        return formatter.string(from: date)
    }
    
    func formatTime(unixTime: Double, timeZoneOffset: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView(viewModel: WeatherViewModel())
}
