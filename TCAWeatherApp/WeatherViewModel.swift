//
//  WeatherViewModel.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import Foundation
import CoreLocation
import CoreLocationUI
import Combine
import SwiftUI

class WeatherViewModel: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    @Published var isLoading = false
    @Published var weatherState: State?
    
    struct State {
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
        
        struct DailyForecast {
            let day: String
            let maxTemp: Double
            let minTemp: Double
            let main: String
        }
        
        init(from weather: ResponseData) {
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 0
            let numberFormatter2 = NumberFormatter()
            numberFormatter2.numberStyle = .percent
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d/M E"
            
            self.name = weather.city.name
            self.day = dateFormatter.string(from: Date(timeIntervalSince1970: weather.list[0].dt))
            self.overview = weather.list[0].weather[0].description.capitalized
            self.temperature = "\(numberFormatter.string(for: weather.list[0].main.temp.tempToCelsius()) ?? "0")°" // 285.45 -> 12
            self.high = "H: \(numberFormatter.string(for: weather.list[0].main.tempMax.tempToCelsius()) ?? "0")°"
            self.low = "L: \(numberFormatter.string(for: weather.list[0].main.tempMin.tempToCelsius()) ?? "0")°"
            self.feels = "\(numberFormatter.string(for: weather.list[0].main.feelsLike.tempToCelsius()) ?? "0")°"
            self.pop = "\(numberFormatter2.string(for: String(format: "%.0f", weather.list[0].pop)) ?? "0%")"
            self.main = "\(weather[0].weather[0].main)"
            self.clouds = "\(weather.list[0].clouds)%"
            self.humidity = "\(String(format: "%.0f", weather.list[0].main.humidity))%"
            self.wind = "\(numberFormatter.string(for: weather.list[0].wind.speed) ?? "0")m/s"
            self.timezone = weather.city.timezone
            self.sunset = weather.city.sunset
            self.sunrise = weather.city.sunrise

            let groupedData = Dictionary(grouping: weather.list) { (element) -> Substring in
                return element.localTime.prefix(10)
            }
            
            self.dailyForecasts = groupedData.compactMap { (key, values) in
                guard let maxTemp = values.max(by: { $0.main.tempMax < $1.main.tempMax }),
                      let minTemp = values.min(by: { $0.main.tempMin < $1.main.tempMin }) else {
                    return nil
                }
                return DailyForecast(
                    day: String(key),
                    maxTemp: maxTemp.main.tempMax,
                    minTemp: minTemp.main.tempMin,
                    main: maxTemp.weather[0].main
                )
            }
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        isLoading = true
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    func formattedTime(from string: String,  timeZoneOffset: Double) -> String? {
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
    
    func formatTime(unixTime: Date, timeZoneOffset: Double) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d, MMM"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
        return formatter.string(from: date)
    }
    
    
    func formattedHourlyTime(time: Double, timeZoneOffset: Double) -> String {
        let date = Date(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
        return formatter.string(from: date)
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
    
    func getWeatherForecast() async {
        // TODO: implement API Request
        try? await Task.sleep(nanoseconds: 300_000_000)
        await MainActor.run {
            self.isLoading = false
            self.weatherState = .init(from: previewData)
        }
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate
        isLoading = false
        Task { await getWeatherForecast() }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("Error, location unknown", error)
            case .denied:
                print("Error, Location denied", error)
            default:
                print("Error getting location", error)
                isLoading = false
            }
        }
    }
}

extension Double {
    func tempToCelsius() -> Double { self - 273.5 }
}
