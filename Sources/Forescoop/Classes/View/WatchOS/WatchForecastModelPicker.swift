//
//  WatchForecastModelPicker.swift
//  Forescoop package
//

#if os(watchOS)
import SwiftUI

/// Selects one of the forecast models already returned for the current spot.
struct WatchForecastModelPicker: View {
    let forecast: SpotForecast
    let selectedModelID: String?
    let select: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(models, id: \.identifier) { model in
                Button {
                    select(model.identifier)
                    dismiss()
                } label: {
                    HStack {
                        Text(model.name)
                        Spacer()
                        if model.identifier == selectedModelID {
                            Image(systemName: "checkmark").foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .navigationTitle("Forecast model")
    }

    private var models: [(identifier: String, name: String)] {
        forecast.forecasts.compactMap { model in
            guard let identifier = model.model else { return nil }
            return (identifier, model.forecast?.modelName ?? "Model \(identifier)")
        }
    }
}
#endif
