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
    private let forecastService: ForecastWindguruProtocol
    private let loginHandler: @MainActor (String, String) async throws -> User?
    let username: String
    let onLoggedIn: (String, Bool) -> Void
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
        onLoggedIn: @escaping (String, Bool) -> Void,
        onProfileLoaded: @escaping (User) -> Void = { _ in }
    ) {
        self.forecastService = forecastService
        loginHandler = { try await forecastService.login(withUsername: $0, password: $1) }
        self.username = username
        self.onLoggedIn = onLoggedIn
        self.onProfileLoaded = onProfileLoaded
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let loggedInUser {
                    WindguruProfileView(
                        user: loggedInUser,
                        forecastService: forecastService,
                        username: enteredUsername,
                        password: password,
                        onSignOut: signOut
                    )
                } else {
                    Form {
                        Section("Windguru account") {
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
                }
            }
            .onAppear {
                enteredUsername = username
                password = WindguruAccount(username: username).password ?? ""
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
            guard let user = try await loginHandler(enteredUsername, password) else {
                throw LoginError.loginFailed
            }
            try WindguruCredentialStore.save(password: password, for: enteredUsername)
            loggedInUser = user
            onProfileLoaded(user)
            onLoggedIn(enteredUsername, user.isPro)
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
            guard let user = try await loginHandler(enteredUsername, password) else {
                throw LoginError.loginFailed
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
        onLoggedIn("", false)
    }
}

private enum LoginError: LocalizedError {
    case loginFailed
    case credentialsUnavailable

    var errorDescription: String? {
        switch self {
        case .loginFailed:
            "Windguru could not sign in with those credentials."
        case .credentialsUnavailable:
            "The password could not be saved securely on this device."
        }
    }
}

public enum WindguruCredentialStore {
    private static let service = "Forescoop.Windguru"
    private static let activeAccountKey = "active-account"

    public static func activeUsername() -> String? {
        string(for: activeAccountKey)
    }

    public static func saveActiveUsername(_ username: String) throws {
        try save(value: username, for: activeAccountKey)
    }

    public static func removeActiveUsername() {
        removeValue(for: activeAccountKey)
    }

    public static func password(for username: String) -> String? {
        string(for: username)
    }

    private static func string(for account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account, kSecReturnData as String: true]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public static func save(password: String, for username: String) throws {
        try save(value: password, for: username)
    }

    private static func save(value: String, for account: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account]
        let attributes = [kSecValueData as String: Data(value.utf8)]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var item = query
            item[kSecValueData as String] = Data(value.utf8)
            guard SecItemAdd(item as CFDictionary, nil) == errSecSuccess else { throw LoginError.credentialsUnavailable }
        } else if status != errSecSuccess {
            throw LoginError.credentialsUnavailable
        }
    }

    public static func removePassword(for username: String) {
        removeValue(for: username)
    }

    private static func removeValue(for account: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
    }
}


//#if DEBUG
//private struct MockForecastWindguruService: ForecastWindguruProtocol {
//    func login(withUsername username: String, password: String) async throws -> User? {
//        // Simulate a small delay
//        try? await Task.sleep(nanoseconds: 200_000_000)
//        return User(id: 12345, name: "Windy Pro", isPro: true)
//    }
//}
//
//#Preview("Windguru Login") {
//    NavigationStack {
//        WindguruLoginView(
//            forecastService: MockForecastWindguruService(),
//            username: "demo_user",
//            onLoggedIn: { _, _ in },
//            onProfileLoaded: { _ in }
//        )
//    }
//}
//#endif

#endif
