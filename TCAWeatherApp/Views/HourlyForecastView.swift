//
//  HourlyForecastView.swift
//  TCAWeatherApp
//
//  Created by Musa Yazici on 2/13/25.
//

import SwiftUI

struct HourlyForecastView: View {
    @State var weatherList: ResponseData.ListResponse
    @State var weather: ResponseData
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text(viewModel.formattedHourlyTime(time: weatherList.dt, timeZoneOffset: weather.city.timezone))
                .font(.caption2)
            viewModel.weatherIcon(for: weatherList.weather[0].main)
                .renderingMode(.original)
                .shadow(radius: 3)
            Text("\(viewModel.convert(weatherList.main.temp).roundDouble())°")
                .bold()
            HStack(spacing: 5) {
                Image(systemName: "drop.fill")
                    .renderingMode(.original)
                    .foregroundColor(Color("Blue"))

                Text((weatherList.main.humidity.roundDouble()) + "%")
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

#Preview {
    HourlyForecastView(weatherList: previewData.list[0], weather: previewData, viewModel: WeatherViewModel(weather: previewData))
}
