//
//  WeatherFeature.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import ComposableArchitecture
import SwiftUI

struct WeatherFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var weatherData: WeatherData?
        
        struct WeatherData: Equatable {
            let name: String
            let day: String
            let overview: String
            let temperature: String
            let high: String
            let low: String
            let feels: String
            let pop: String
            let main: String
            let clouds: String
            let humidity: String
            let wind: String
            let timezone: Double
            let sunrise: Double
            let sunset: Double
            let dailyForecasts: [DailyForecast]
        }
        
        struct DailyForecast: Equatable {
            let day: String
            let maxTemp: Double
            let minTemp: Double
            let main: String
        }
    }
    
    enum Action: Equatable {
        case fetchWeather
        case weatherResponse(TaskResult<ResponseData>)
        case locationRequested
    }
    
    @Dependency(\.weatherClient) var weatherClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchWeather:
                state.isLoading = true
                return .run { send in
                    await send(.weatherResponse(TaskResult {
                        try await weatherClient.fetchWeather()
                    }))
                }
                
            case let .weatherResponse(.success(response)):
                state.isLoading = false
                state.weatherData = mapResponseToWeatherData(response)
                return .none
                
            case .weatherResponse(.failure):
                state.isLoading = false
                return .none
                
            case .locationRequested:
                return .send(.fetchWeather)
            }
        }
    }
    
    private func mapResponseToWeatherData(_ weather: ResponseData) -> State.WeatherData {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        let numberFormatter2 = NumberFormatter()
        numberFormatter2.numberStyle = .percent
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d/M E"
        
        let groupedData = Dictionary(grouping: weather.list) { $0.localTime.prefix(10) }
        
        let dailyForecasts = groupedData.compactMap { (key, values) -> State.DailyForecast? in
            guard let maxTemp = values.max(by: { $0.main.tempMax < $1.main.tempMax }),
                  let minTemp = values.min(by: { $0.main.tempMin < $1.main.tempMin }) else {
                return nil
            }
            return State.DailyForecast(
                day: String(key),
                maxTemp: maxTemp.main.tempMax,
                minTemp: minTemp.main.tempMin,
                main: maxTemp.weather[0].main
            )
        }
        
        return State.WeatherData(
            name: weather.city.name,
            day: dateFormatter.string(from: Date(timeIntervalSince1970: weather.list[0].dt)),
            overview: weather.list[0].weather[0].description.capitalized,
            temperature: "\(numberFormatter.string(for: weather.list[0].main.temp.tempToCelsius()) ?? "0")°",
            high: "H: \(numberFormatter.string(for: weather.list[0].main.tempMax.tempToCelsius()) ?? "0")°",
            low: "L: \(numberFormatter.string(for: weather.list[0].main.tempMin.tempToCelsius()) ?? "0")°",
            feels: "\(numberFormatter.string(for: weather.list[0].main.feelsLike.tempToCelsius()) ?? "0")°",
            pop: "\(numberFormatter2.string(for: String(format: "%.0f", weather.list[0].pop)) ?? "0%")",
            main: "\(weather.list[0].weather[0].main)",
            clouds: "\(weather.list[0].clouds)%",
            humidity: "\(String(format: "%.0f", weather.list[0].main.humidity))%",
            wind: "\(numberFormatter.string(for: weather.list[0].wind.speed) ?? "0")m/s",
            timezone: weather.city.timezone,
            sunrise: weather.city.sunrise,
            sunset: weather.city.sunset,
            dailyForecasts: dailyForecasts
        )
    }
}

extension Double {
    func tempToCelsius() -> Double { self - 273.5 }
}
