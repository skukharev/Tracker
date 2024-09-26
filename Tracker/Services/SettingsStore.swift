//
//  SettingsStore.swift
//  Tracker
//
//  Created by Сергей Кухарев on 25.09.2024.
//

import Foundation

final class SettingsStorage {
    // MARK: - Public Properties

    static let shared = SettingsStorage()

    // MARK: - Private Properties

    private let onboardingDidShowIdentifier = "onboardingDidShow"

    // MARK: - Initializers

    private init() {
    }

    // MARK: - Public Methods

    var onboardingDidShow: Bool {
        get {
            return UserDefaults.standard.integer(forKey: onboardingDidShowIdentifier) == 0 ? false : true
        }
        set {
            UserDefaults.standard.set(newValue ? 1 : 0, forKey: onboardingDidShowIdentifier)
            }
    }
}
