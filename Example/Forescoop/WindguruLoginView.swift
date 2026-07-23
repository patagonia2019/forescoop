//
//  WindguruLoginView.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

import Security
import SwiftUI
import Forescoop

struct WindguruLoginView: View {
    let forecastService: ForecastWindguruProtocol
    let username: String
    let onLoggedIn: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var enteredUsername = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Windguru PRO") {
                    TextField("Username", text: $enteredUsername)
#if !os(macOS)
                        .textInputAutocapitalization(.never)
#endif
                        .autocorrectionDisabled()
                    SecureField("Password", text: $password)
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Windguru Login")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Login") { Task { await login() } }
                        .disabled(enteredUsername.isEmpty || password.isEmpty || isLoading)
                }
            }
            .onAppear {
                enteredUsername = username
                password = WindguruCredentialStore.password(for: username) ?? ""
            }
            .overlay { if isLoading { ProgressView("Signing in…") } }
        }
    }

    @MainActor
    private func login() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            guard let user = try await forecastService.login(withUsername: enteredUsername, password: password), user.isPro else {
                throw LoginError.proRequired
            }
            try WindguruCredentialStore.save(password: password, for: enteredUsername)
            onLoggedIn(enteredUsername)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private enum LoginError: LocalizedError {
    case proRequired
    var errorDescription: String? { "A Windguru PRO account is required for coordinate forecasts." }
}

enum WindguruCredentialStore {
    static func password(for username: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Forescoop.Windguru",
                                    kSecAttrAccount as String: username,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func save(password: String, for username: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Forescoop.Windguru",
                                    kSecAttrAccount as String: username]
        let attributes = [kSecValueData as String: Data(password.utf8)]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var item = query
            item[kSecValueData as String] = Data(password.utf8)
            guard SecItemAdd(item as CFDictionary, nil) == errSecSuccess else { throw LoginError.proRequired }
        } else if status != errSecSuccess {
            throw LoginError.proRequired
        }
    }
}
