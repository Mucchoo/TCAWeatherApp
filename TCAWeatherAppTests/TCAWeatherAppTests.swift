//
//  WeatherFeatureTests.swift
//  TCAWeatherAppTests
//
//  Created by Musa Yazici on 2/13/25.
//

import XCTest
import ComposableArchitecture
@testable import TCAWeatherApp

@MainActor
final class WeatherFeatureTests: XCTestCase {
    // MARK: - Mock Data
    let mockResponseData = ResponseData(
        cod: "200",
        message: 0.0,
        cnt: 40,
        list: [
            ResponseData.ListResponse(
                dt: 1677766800,
                main: ResponseData.MainResponse(
                    temp: 293.15, // 20°C
                    feelsLike: 292.15, // 19°C
                    tempMin: 291.15, // 18°C
                    tempMax: 295.15, // 22°C
                    pressure: 1013,
                    seaLevel: 1013,
                    groundLevel: 1010,
                    humidity: 75,
                    tempKf: 0.0
                ),
                weather: [
                    ResponseData.WeatherResponse(
                        id: 802,
                        main: "Clouds",
                        description: "scattered clouds",
                        icon: "03d"
                    )
                ],
                clouds: ResponseData.CloudsResponse(all: 40),
                wind: ResponseData.WindResponse(
                    speed: 3.5,
                    deg: 260,
                    gust: 4.5
                ),
                visibility: 10000,
                pop: 0.2,
                rain: nil,
                sys: ResponseData.SysResponse(pod: "d"),
                localTime: "2024-03-02 12:00:00"
            )
        ],
        city: ResponseData.CityResponse(
            id: 2643743,
            name: "London",
            coord: ResponseData.Coordinations(lat: 51.5074, lon: -0.1278),
            country: "GB",
            population: 8961989,
            timezone: 0,
            sunrise: 1677737400,
            sunset: 1677777800
        )
    )
    
    // MARK: - Tests
    func testFetchWeatherSuccess() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { [self] in
                mockResponseData
            }
        }
        
        await store.send(.fetchWeather) {
            $0.isLoading = true
        }
        
        await store.receive(.weatherResponse(.success(mockResponseData))) {
            $0.isLoading = false
            $0.weatherData = WeatherFeature.State.WeatherData(
                name: "London",
                day: DateFormatter().string(from: Date(timeIntervalSince1970: 1677766800)),
                overview: "Scattered clouds",
                temperature: "20°",
                high: "H: 22°",
                low: "L: 18°",
                feels: "19°",
                pop: "20%",
                main: "Clouds",
                clouds: "40%",
                humidity: "75%",
                wind: "4m/s",
                timezone: 0,
                sunrise: 1677737400,
                sunset: 1677777800,
                dailyForecasts: [
                    WeatherFeature.State.DailyForecast(
                        day: "2024-03-02",
                        maxTemp: 295.15,
                        minTemp: 291.15,
                        main: "Clouds"
                    )
                ]
            )
        }
    }
    
    func testFetchWeatherFailure() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = {
                struct WeatherError: Error {}
                throw WeatherError()
            }
        }
        
        await store.send(.fetchWeather) {
            $0.isLoading = true
        }
        
        await store.receive(.weatherResponse(.failure(URLError(.badServerResponse)))) {
            $0.isLoading = false
        }
    }
    
    func testLocationRequestedTriggersWeatherFetch() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { [self] in
                mockResponseData
            }
        }
        
        await store.send(.locationRequested)
        
        await store.receive(.fetchWeather) {
            $0.isLoading = true
        }
        
        await store.receive(.weatherResponse(.success(mockResponseData))) {
            $0.isLoading = false
            $0.weatherData = WeatherFeature.State.WeatherData(
                name: "London",
                day: DateFormatter().string(from: Date(timeIntervalSince1970: 1677766800)),
                overview: "Scattered clouds",
                temperature: "20°",
                high: "H: 22°",
                low: "L: 18°",
                feels: "19°",
                pop: "20%",
                main: "Clouds",
                clouds: "40%",
                humidity: "75%",
                wind: "4m/s",
                timezone: 0,
                sunrise: 1677737400,
                sunset: 1677777800,
                dailyForecasts: [
                    WeatherFeature.State.DailyForecast(
                        day: "2024-03-02",
                        maxTemp: 295.15,
                        minTemp: 291.15,
                        main: "Clouds"
                    )
                ]
            )
        }
    }
}
