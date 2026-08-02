//
//  WatchAboutView.swift
//  Forescoop package
//

#if os(watchOS)
import SwiftUI

/// A deliberately compact About screen for the watch app.
struct WatchAboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 5) {
                    Image(systemName: "wind")
                        .font(.title)
                        .foregroundStyle(.tint)
                    Text("Ventus").font(.headline)
                    Text("Wind and weather forecasts")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                LabeledContent("Version", value: versionDescription)
                Link(destination: URL(string: "https://github.com/patagonia2019/forescoop")!) {
                    Label("Ventus on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }
            }
        }
        .navigationTitle("About")
    }

    private var versionDescription: String {
        let bundle = Bundle.main
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        guard let build, build != version else { return version }
        return "\(version) (\(build))"
    }
}
#endif
