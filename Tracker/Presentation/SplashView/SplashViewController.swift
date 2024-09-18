//
//  SplashViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 27.07.2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties

    /// Логотип приложения
    private lazy var applicationLogo: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = Asset.appLogo.image
        image.contentMode = .center
        return image
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
        switchToOnboardingScreen()
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appBlue
        view.addSubviews([applicationLogo])
        setupConstraints()
    }

    // Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Логотип приложения
            applicationLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            applicationLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    /// Переключает rootViewController на экран онбординга
    private func switchToOnboardingScreen() {
        let targetViewController = OnboardingScreenAssembley.build()
        let router = Router(viewController: self, targetViewController: targetViewController)
        router.showNext()
    }
}
