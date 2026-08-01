//
//  WindguruLoginView.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

#if !os(watchOS)
import Foundation
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

    var errorDescription: String? {
        switch self {
        case .loginFailed:
            "Windguru could not sign in with those credentials."
        }
    }
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
