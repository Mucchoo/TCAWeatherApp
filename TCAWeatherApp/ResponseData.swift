//
//  ResponseData.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

var previewData: ResponseData = load("ResponseData.json")

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        print(error)
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

struct ResponseData: Decodable, Identifiable, RandomAccessCollection, Hashable {
    static func == (lhs: ResponseData, rhs: ResponseData) -> Bool {
        return lhs.cod == rhs.cod && lhs.city == rhs.city
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(cod)
        hasher.combine(city)
    }
    
    var startIndex: Int { list.startIndex }
    var endIndex: Int { list.endIndex }
    func formIndex(after i: inout Int) { i += 1 }
    func formIndex(before i: inout Int) { i -= 1 }
    subscript(index: Int) -> ListResponse {
        return list[index]
    }
    
    let id = UUID()
    
    let cod: String
    let message: Double?
    let cnt: Double?
    let list: [ListResponse]
    let city: CityResponse
    
    enum CodingKeys: String, CodingKey {
        case cod
        case message
        case cnt
        case list
        case city
    }
    
    struct ListResponse: Decodable, Identifiable, RandomAccessCollection, Hashable {
        static func == (lhs: ResponseData.ListResponse, rhs: ResponseData.ListResponse) -> Bool {
            return lhs.dt == rhs.dt && lhs.localTime == rhs.localTime
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(dt)
            hasher.combine(localTime)
        }
        
        var startIndex: Int { weather.startIndex }
        var endIndex: Int { weather.endIndex }
        func formIndex(after i: inout Int) { i += 1 }
        func formIndex(before i: inout Int) { i -= 1 }
        subscript(index: Int) -> WeatherResponse {
            return weather[index]
        }
        
        let id = UUID()
        
        let dt: Double
        let main: MainResponse
        let weather: [WeatherResponse]
        let clouds: CloudsResponse
        let wind: WindResponse
        let visibility: Double
        let pop: Double
        let rain: RainResponse?
        let sys: SysResponse
        let localTime: String
        
        enum CodingKeys: String, CodingKey {
            case dt
            case main
            case weather
            case clouds
            case wind
            case visibility
            case pop
            case rain
            case sys
            case localTime = "dt_txt"
        }
    }
    
    struct MainResponse: Decodable, Identifiable {
        var id = UUID()
        
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Double
        let seaLevel: Double
        let groundLevel: Double
        let humidity: Double
        let tempKf: Double
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case seaLevel = "sea_level"
            case groundLevel = "grnd_level"
            case humidity
            case tempKf = "temp_kf"
        }
    }
    
    struct WeatherResponse: Decodable {
        let id: Double
        let main: String
        let description: String
        let icon: String
    }
    
    struct CloudsResponse: Decodable {
        let all: Double
    }
    
    struct WindResponse: Decodable {
        let speed: Double
        let deg: Double
        let gust: Double
    }
    
    struct RainResponse: Decodable {
        let oneHour: Double
        
        enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
        }
    }
    
    struct SysResponse: Codable {
        
        let pod: String
    }
    
    struct CityResponse: Codable, Identifiable, Hashable {
        static func == (lhs: ResponseData.CityResponse, rhs: ResponseData.CityResponse) -> Bool {
            return lhs.id == rhs.id && lhs.sunset == rhs.sunset
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(sunset)
        }
        
        let id: Double
        let name: String
        let coord: Coordinations
        let country: String
        let population: Double
        let timezone: Double
        let sunrise: Double
        let sunset: Double
    }
    
    struct Coordinations: Codable {
        let lat: Double?
        let lon: Double?
    }
}

extension ResponseData.CityResponse: RandomAccessCollection {
    var startIndex: String.Index {
        return name.startIndex
    }

    var endIndex: String.Index {
        return name.endIndex
    }

    func index(after i: String.Index) -> String.Index {
        return name.index(after: i)
    }

    func index(before i: String.Index) -> String.Index {
        return name.index(before: i)
    }

    subscript(position: String.Index) -> Character {
        return name[position]
    }
}

