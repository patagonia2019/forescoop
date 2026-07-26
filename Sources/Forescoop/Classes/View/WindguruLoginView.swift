//
//  WindguruLoginView.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

#if !os(watchOS)
import Security
import SwiftUI

public struct WindguruLoginView: View {
    private let loginHandler: @MainActor (String, String) async throws -> User?
    let username: String
    let onLoggedIn: (String) -> Void
    let onProfileLoaded: (User) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var enteredUsername = ""
    @State private var password = ""
    @State private var showsPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var loggedInUser: User?

    public init(
        forecastService: ForecastWindguruProtocol,
        username: String,
        onLoggedIn: @escaping (String) -> Void,
        onProfileLoaded: @escaping (User) -> Void = { _ in }
    ) {
        loginHandler = { try await forecastService.login(withUsername: $0, password: $1) }
        self.username = username
        self.onLoggedIn = onLoggedIn
        self.onProfileLoaded = onProfileLoaded
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let loggedInUser {
                    WindguruProfileView(user: loggedInUser)
                } else {
                    Form {
                        Section("Windguru PRO") {
                            TextField("Username", text: $enteredUsername)
#if !os(macOS)
                                .textInputAutocapitalization(.never)
#endif
                                .autocorrectionDisabled()
                            HStack {
                                Group {
                                    if showsPassword {
                                        TextField("Password", text: $password)
                                    } else {
                                        SecureField("Password", text: $password)
                                    }
                                }
#if !os(macOS)
                                .textInputAutocapitalization(.never)
#endif
                                .autocorrectionDisabled()

                                Button {
                                    showsPassword.toggle()
                                } label: {
                                    Image(systemName: showsPassword ? "eye.slash" : "eye")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(showsPassword ? "Hide password" : "Show password")
                            }
                        }
                        if let errorMessage {
                            Section { Text(errorMessage).foregroundStyle(.red) }
                        }
                    }
                }
            }
            .navigationTitle(loggedInUser == nil ? "Windguru Login" : "Windguru Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                if loggedInUser == nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Login") { Task { await login() } }
                            .disabled(enteredUsername.isEmpty || password.isEmpty || isLoading)
                    }
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Sign Out", role: .destructive) { signOut() }
                    }
                }
            }
            .onAppear {
                enteredUsername = username
                password = WindguruCredentialStore.password(for: username) ?? ""
                if !enteredUsername.isEmpty, !password.isEmpty {
                    Task { await loadProfile() }
                }
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
            guard let user = try await loginHandler(enteredUsername, password), user.isPro else {
                throw LoginError.proRequired
            }
            try WindguruCredentialStore.save(password: password, for: enteredUsername)
            loggedInUser = user
            onProfileLoaded(user)
            onLoggedIn(enteredUsername)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            guard let user = try await loginHandler(enteredUsername, password), user.isPro else {
                throw LoginError.proRequired
            }
            loggedInUser = user
            onProfileLoaded(user)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func signOut() {
        WindguruCredentialStore.removePassword(for: enteredUsername)
        loggedInUser = nil
        password = ""
        onLoggedIn("")
    }
}

private enum LoginError: LocalizedError {
    case proRequired
    var errorDescription: String? { "A Windguru PRO account is required for coordinate forecasts." }
}

public enum WindguruCredentialStore {
    public static func password(for username: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Forescoop.Windguru",
                                    kSecAttrAccount as String: username,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public static func save(password: String, for username: String) throws {
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

    public static func removePassword(for username: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Forescoop.Windguru",
                                    kSecAttrAccount as String: username]
        SecItemDelete(query as CFDictionary)
    }
}
#endif
