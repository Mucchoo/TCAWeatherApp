//
//  WeatherClient.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import Foundation
import ComposableArchitecture

struct WeatherClient {
    var fetchWeather: () async throws -> ResponseData
}

extension WeatherClient: DependencyKey {
    static let liveValue = WeatherClient(
        fetchWeather: {
            // TODO: Implement actual API request
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return previewData
        }
    )
}
