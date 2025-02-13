//
//  WeatherView.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import CoreLocationUI
import SwiftUI
import ComposableArchitecture

struct WeatherView: View {
    let store: StoreOf<WeatherFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                if let weather = viewStore.weatherData {
                    ScrollView(showsIndicators: false) {
                        scrollViewContent(weather: weather)
                            .padding()
                            .aspectRatio(1.0, contentMode: .fill)
                    }
                } else if viewStore.isLoading {
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
                            viewStore.send(.locationRequested)
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
    }
    
    private func scrollViewContent(weather: WeatherFeature.State.WeatherData) -> some View {
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
                weatherIcon(for: weather.main)
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
    
    private func sunriseView(_ weather: WeatherFeature.State.WeatherData) -> some View {
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
    
    private func dailyForecastsView(_ weather: WeatherFeature.State.WeatherData) -> some View {
        let sortedDailyForecasts = weather.dailyForecasts.sorted { $0.day < $1.day }
        
        return VStack(alignment: .leading) {
            ForEach(sortedDailyForecasts, id: \.day) { dailyForecast in
                HStack {
                    HStack {
                        Text(formattedTime(from: dailyForecast.day, timeZoneOffset: weather.timezone) ?? "")
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        weatherIcon(for: dailyForecast.main)
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
}

// MARK: - Helper Functions
extension WeatherView {
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
    
    func formattedTime(from string: String, timeZoneOffset: Double) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "YY/MM/dd"
        
        if let date = inputFormatter.date(from: string) {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d/M E"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func weatherIcon(for condition: String) -> Image {
        switch condition {
        case "Clear":
            return Image(systemName: "sun.max.fill")
        case "Clouds":
            return Image(systemName: "cloud.fill")
        case "Rain":
            return Image(systemName: "cloud.rain.fill")
        case "Snow":
            return Image(systemName: "cloud.snow.fill")
        default:
            return Image(systemName: "questionmark")
        }
    }
}

extension DependencyValues {
    var weatherClient: WeatherClient {
        get { self[WeatherClient.self] }
        set { self[WeatherClient.self] = newValue }
    }
}

#Preview {
    WeatherView(
        store: Store(
            initialState: WeatherFeature.State(),
            reducer: { WeatherFeature() }
        )
    )
}
