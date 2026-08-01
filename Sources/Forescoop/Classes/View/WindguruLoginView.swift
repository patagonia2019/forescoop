//
//  WindguruLoginView.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

#if !os(watchOS)
import Foundation
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
#if DEBUG
                        if isRunningInXcodePreview {
                            Section("Preview") {
                                Button("Use Preview PRO Account", systemImage: "checkmark.seal") {
                                    usePreviewProAccount()
                                }
                                Button("Use Preview Regular Account", systemImage: "person") {
                                    usePreviewRegularAccount()
                                }
                            }
                        }
#endif
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

#if DEBUG
    private var isRunningInXcodePreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    @MainActor
    private func usePreviewProAccount() {
        usePreviewAccount(username: "preview-pro", isProUser: true)
    }

    @MainActor
    private func usePreviewRegularAccount() {
        usePreviewAccount(username: "preview-regular", isProUser: false)
    }

    @MainActor
    private func usePreviewAccount(username previewUsername: String, isProUser: Bool) {
        let previewPassword = "preview-only"
        guard let user = try? User(map: [
            "id_user": 1,
            "username": previewUsername,
            "pro": isProUser ? 1 : 0,
            "no_ads": 1,
            "wind_units": "knots",
            "temp_units": "c",
            "wave_units": "m",
            "view_hours_from": 3,
            "view_hours_to": 22
        ]) else {
            return
        }

        enteredUsername = previewUsername
        password = previewPassword
        try? WindguruCredentialStore.save(password: previewPassword, for: previewUsername)
        loggedInUser = user
        onProfileLoaded(user)
        onLoggedIn(previewUsername, isProUser)
    }
#endif
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
    private static let activeProUserKey = "active-pro-user"
#if DEBUG
    private static let debugFallbackPrefix = "Forescoop.Windguru.Debug."
#endif

    public static func activeUsername() -> String? {
        string(for: activeAccountKey)
    }

    public static func saveActiveUsername(_ username: String) throws {
        try save(value: username, for: activeAccountKey)
    }

    public static func removeActiveUsername() {
        removeValue(for: activeAccountKey)
    }

    public static func activeProUser() -> Bool {
        string(for: activeProUserKey) == "true"
    }

    public static func saveActiveProUser(_ isProUser: Bool) throws {
        try save(value: isProUser ? "true" : "false", for: activeProUserKey)
    }

    public static func removeActiveProUser() {
        removeValue(for: activeProUserKey)
    }

    public static func password(for username: String) -> String? {
        string(for: username)
    }

    private static func string(for account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account, kSecReturnData as String: true]
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
           let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }
#if DEBUG
        return UserDefaults.standard.string(forKey: debugFallbackKey(for: account))
#else
        return nil
#endif
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
            if SecItemAdd(item as CFDictionary, nil) == errSecSuccess { return }
        } else if status != errSecSuccess {
            // Fall through to the DEBUG-only Preview fallback below.
        } else {
            return
        }
#if DEBUG
        UserDefaults.standard.set(value, forKey: debugFallbackKey(for: account))
#else
        throw LoginError.credentialsUnavailable
#endif
    }

    public static func removePassword(for username: String) {
        removeValue(for: username)
    }

    private static func removeValue(for account: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
#if DEBUG
        UserDefaults.standard.removeObject(forKey: debugFallbackKey(for: account))
#endif
    }

#if DEBUG
    private static func debugFallbackKey(for account: String) -> String {
        debugFallbackPrefix + account
    }
#endif
}


#if DEBUG
#Preview("Windguru Login") {
    WindguruLoginView(
        forecastService: ForecastWindguruMockup(),
        username: "",
        onLoggedIn: { _, _ in },
        onProfileLoaded: { _ in }
    )
}
#endif

#endif
