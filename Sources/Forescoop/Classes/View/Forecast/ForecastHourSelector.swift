//
//  ForecastHourSelector.swift
//  Forescoop
//

#if !os(watchOS)
import SwiftUI

public struct ForecastHourSelector: View {
    public let forecast: SpotForecast
    @Binding public var selectedHour: String?

    public init(
        forecast: SpotForecast,
        selectedHour: Binding<String?>
    ) {
        self.forecast = forecast
        _selectedHour = selectedHour
    }

    private var hours: [String] {
        forecast.availableForecastHours
    }

    private var currentHour: String? {
        let now = Date()
        return hours.last(where: { (forecast.forecastDate(hour: $0) ?? .distantFuture) <= now })
            ?? hours.first
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
    }

    private func moveSelection(by offset: Int) {
        guard let selectedIndex else { return }
        selectedHour = hours[hours.index(selectedIndex, offsetBy: offset)]
    }

    private func hourLabel(for hour: String) -> String {
        guard let date = forecast.forecastDate(hour: hour) else {
            return String(format: "%02d:00", (Int(hour) ?? 0) % 24)
        }

        let calendar = Calendar.current
        let day = calendar.isDateInToday(date)
            ? "Today"
            : date.formatted(.dateTime.weekday(.abbreviated).day())
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        // The localized `j` hour skeleton follows the user's 12/24-hour
        // preference while omitting minutes: "9 AM" or "21".
        formatter.setLocalizedDateFormatFromTemplate("j")
        let suffix = formatter.dateFormat.contains("a") ? "" : " hs"
        return "\(day), \(formatter.string(from: date))\(suffix)"
    }
}

#if DEBUG
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
#endif
