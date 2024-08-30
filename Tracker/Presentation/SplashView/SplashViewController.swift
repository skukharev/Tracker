//
//  SplashViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 27.07.2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Types

    private enum Constants {
        static let applicationLogoImageName = "AppLogo"
        static let trackersTabBarImageName = "TrackersTabBarImage"
        static let statisticsTabBarImageName = "StatisticsTabBarImage"
        static let trackersTabBarItemTitle = "Трекеры"
        static let statisticsTabBarItemTitle = "Статистика"
    }

    // MARK: - Private Properties

    /// Логотип приложения
    private lazy var applicationLogo: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        guard let appImage = UIImage(named: Constants.applicationLogoImageName) else {
            assertionFailure("Ошибка загрузки логотипа приложения")
            return image
        }
        image.image = appImage
        image.contentMode = .center
        return image
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
        switchToMainScreen()
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

    /// Переключает rootViewController на главный экран приложения
    private func switchToMainScreen() {
        // Создание вью контроллера для экрана с трекерами
        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem = UITabBarItem(title: Constants.trackersTabBarItemTitle, image: UIImage(named: Constants.trackersTabBarImageName), tag: 1)
        let trackersViewPresenter = TrackersViewPresenter()
        trackersViewController.configure(trackersViewPresenter)
        // Создание вью контроллера для экрана со статистикой
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: Constants.statisticsTabBarItemTitle, image: UIImage(named: Constants.statisticsTabBarImageName), tag: 2)
        let statisticsViewPresenter = StatisticsViewPresenter()
        statisticsViewController.configure(statisticsViewPresenter)
        // Создание вью контроллера для таб-бара
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [UINavigationController(rootViewController: trackersViewController), UINavigationController(rootViewController: statisticsViewController)]
        /// Настройка цвета фона таб-бара
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .appWhite
        appearance.shadowColor = nil
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        /// Настройка цвета окантовки таб-бара
        tabBarController.tabBar.addTopBorder(with: .appTabBarTopBorder, andWidth: 1)
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Ошибка получения ссылки на экран устройства")
            return
        }
        window.rootViewController = tabBarController
    }
}
