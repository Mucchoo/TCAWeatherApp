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
    var weatherManager = WeatherManager()
    @State var weather: ResponseData?
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            if let weather {
                ScrollView(showsIndicators: false) {
                    scrollViewContent(weather: weather)
                    .padding()
                    .aspectRatio(1.0, contentMode: .fill)
                    .onAppear {
                        viewModel.getWeatherForecast()
                    }
                }
            }
        }
        .background(Color(.systemBackground).opacity(0.8))
    }
    
    private func scrollViewContent(weather: ResponseData) -> some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(formatedTime(time: Date.now, timeZoneOffset: viewModel.weather.city.timezone))
                        .font(.caption2)
                        .bold()
                    Text(viewModel.temperature)
                        .font(.system(size: 40))
                    Text(viewModel.weather.city.name)
                        .font(.body)
                        .bold()
                }
                Spacer()
                viewModel.weatherIcon(for: viewModel.main)
                    .renderingMode(.original)
                    .font(.system(size: 50))
                    .shadow(radius: 5)
            }
            .padding()
            .background(Color.white)
            .foregroundColor(.primary)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            
            hourlyForecastsView(weather: weather)
            sunriseView
            dailyForecastsView
        }
    }
    
    private func hourlyForecastsView(weather: ResponseData) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.weather.list, id: \.self) { weatherList in
                    VStack(spacing: 10) {
                        Text(viewModel.formattedHourlyTime(time: weatherList.dt, timeZoneOffset: weather.city.timezone))
                            .font(.caption2)
                        viewModel.weatherIcon(for: weatherList.weather[0].main)
                            .renderingMode(.original)
                            .shadow(radius: 3)
                        Text("\(String(format: "%.0f", viewModel.convert(weatherList.main.temp)))°")
                            .bold()
                        HStack(spacing: 5) {
                            Image(systemName: "drop.fill")
                                .renderingMode(.original)
                                .foregroundColor(Color("Blue"))
                            
                            Text((String(format: "%.0f", weatherList.main.humidity)) + "%")
                        }
                        .font(.caption)
                    }
                    .frame(minWidth: 10, minHeight: 80)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.primary)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
            }
        }
    }
    
    private var sunriseView: some View {
        HStack {
            Text("Sunrise")
                .bold()
            Image(systemName: "sun.max.fill")
                .renderingMode(.original)
            Text(formatTime(unixTime: viewModel.weather.city.sunrise, timeZoneOffset: viewModel.weather.city.timezone))
            Spacer()
            Text("Sunset")
                .bold()
            Image(systemName: "moon.fill")
                .foregroundColor(Color("DarkBlue"))
            Text(formatTime(unixTime: viewModel.weather.city.sunset, timeZoneOffset: viewModel.weather.city.timezone))
        }
        .font(.body)
        .padding()
        .background(Color.white)
        .foregroundColor(.primary)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    private var dailyForecastsView: some View {
        let sortedDailyForecasts = viewModel.dailyForecasts.sorted { $0.day < $1.day }
        
        return VStack(alignment: .leading) {
            ForEach(sortedDailyForecasts, id: \.day) { dailyForecast in
                HStack {
                    HStack {
                        Text(viewModel.formattedTime(from: dailyForecast.day, timeZoneOffset: viewModel.weather.city.timezone) ?? viewModel.day)
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
                        Text("\(String(format: "%.0f", viewModel.convert(dailyForecast.maxTemp)))°")
                        Text("\(String(format: "%.0f", viewModel.convert(dailyForecast.minTemp)))°")
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
    ContentView(viewModel: WeatherViewModel(weather: previewData))
}
