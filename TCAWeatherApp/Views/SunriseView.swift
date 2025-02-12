//
//  SunriseView.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import SwiftUI

struct SunriseView: View {
    @StateObject var viewModel: WeatherViewModel
    
    var body: some View {
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
    
    func formatTime(unixTime: Double, timeZoneOffset: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
        return formatter.string(from: date)
    }
}

#Preview {
    SunriseView(viewModel: WeatherViewModel(weather: previewData))
}
