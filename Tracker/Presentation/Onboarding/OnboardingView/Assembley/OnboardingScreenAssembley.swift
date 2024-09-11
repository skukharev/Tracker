//
//  OnboardingScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 08.09.2024.
//

import UIKit

enum OnboardingScreenAssembley {
    /// Инициализирует вью контроллер перед отображением на экране
    /// - Returns: вью контроллер, готовый к показу на экране
    static func build() -> UIViewController {
        let onboardingViewController = OnboardingViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        let onboardingViewPresenter = OnboardingViewPresenter()
        onboardingViewController.presenter = onboardingViewPresenter
        onboardingViewPresenter.viewController = onboardingViewController
        return onboardingViewController
    }
}
