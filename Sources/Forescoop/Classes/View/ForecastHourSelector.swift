//
//  ForecastHourSelector.swift
//  Forescoop
//

#if !os(watchOS)
import SwiftUI

public enum ForecastDisplayInterval: Int, CaseIterable, Identifiable, Sendable {
    case hourly = 1
    case every3Hours = 3
    case every6Hours = 6

    public var id: Int { rawValue }
    public var title: String { "Every \(rawValue) hour\(rawValue == 1 ? "" : "s")" }
}

public struct ForecastHourSelector: View {
    public let forecast: SpotForecast
    @Binding public var selectedHour: String?
    public let displayInterval: ForecastDisplayInterval

    public init(
        forecast: SpotForecast,
        selectedHour: Binding<String?>,
        displayInterval: ForecastDisplayInterval = .hourly
    ) {
        self.forecast = forecast
        _selectedHour = selectedHour
        self.displayInterval = displayInterval
    }

    private var hours: [String] {
        forecast.availableForecastHours.filter { hour in
            guard let value = Int(hour) else { return false }
            return value.isMultiple(of: displayInterval.rawValue)
        }
    }

    private var currentHour: String? {
        hours.min {
            abs((forecast.forecastDate(hour: $0)?.timeIntervalSinceNow ?? .greatestFiniteMagnitude))
                < abs((forecast.forecastDate(hour: $1)?.timeIntervalSinceNow ?? .greatestFiniteMagnitude))
        }
    }

    private var selection: String? {
        selectedHour ?? currentHour
    }

    private var selectedIndex: Int? {
        selection.flatMap { hours.firstIndex(of: $0) }
    }

    public var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Button {
                moveSelection(by: -1)
            } label: {
                Label("Previous forecast hour", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
            }
            .disabled(selectedIndex == nil || selectedIndex == 0)


            Spacer()

            Picker("Forecast date and hour", selection: $selectedHour) {
                ForEach(hours, id: \.self) { hour in
                    Text(hourLabel(for: hour))
                        .fontWeight(hour == currentHour ? .bold : .regular)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                        .tag(Optional(hour))
                }
            }
            .pickerStyle(.menu)
            .fontWeight(selection == currentHour ? .bold : .regular)
            .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button {
                moveSelection(by: 1)
            } label: {
                Label("Next forecast hour", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
            }
            .disabled(selectedIndex == nil || selectedIndex == hours.count - 1)
        }
        .accessibilityElement(children: .contain)
        .onChange(of: displayInterval) {
            if let selectedHour, !hours.contains(selectedHour) {
                self.selectedHour = currentHour
            }
        }
    }

    private func moveSelection(by offset: Int) {
        guard let selectedIndex else { return }
        selectedHour = hours[hours.index(selectedIndex, offsetBy: offset)]
    }

    private func hourLabel(for hour: String) -> String {
        guard let date = forecast.forecastDate(hour: hour) else {
            return String(format: "%02d hs", (Int(hour) ?? 0) % 24)
        }

        let calendar = Calendar.current
        let day = calendar.isDateInToday(date)
            ? "Today"
            : date.formatted(.dateTime.weekday(.abbreviated).day())
        return "\(day), \(date.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)))) hs"
    }
}

#Preview {
    ForecastHourSelectorPreview()
        .padding()
}

private struct ForecastHourSelectorPreview: View {
    @State private var selectedHour: String?

    var body: some View {
        ForecastHourSelector(forecast: Self.forecast, selectedHour: $selectedHour)
    }

    private static let forecast: SpotForecast =
        try! SpotForecast(map: Definition().json(jsonFile: "SpotForecast"))!
}
#endif
