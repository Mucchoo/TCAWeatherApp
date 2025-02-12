//
//  TopWeatherView.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import SwiftUI
import CoreLocation

struct TopWeatherView: View {
    @StateObject var viewModel: WeatherViewModel
    
    var body: some View {
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
}
    
    func formatedTime(time: Date, timeZoneOffset: Double) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E, HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
        return formatter.string(from: date)
    }
}

#Preview {
    TopWeatherView(viewModel: WeatherViewModel(weather: previewData))
}
