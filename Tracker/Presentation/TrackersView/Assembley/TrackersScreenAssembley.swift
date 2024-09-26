//
//  TrackersScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 09.09.2024.
//

import UIKit

enum TrackersScreenAssembley {
    /// Инициализирует вью контроллер перед отображением на экране
    /// - Returns: вью контроллер, готовый к показу на экране
    static func build() -> UIViewController {
        let trackersViewPresenter = TrackersViewPresenter()
        let trackersViewController = TrackersViewController(withPresenter: trackersViewPresenter)
        trackersViewController.tabBarItem = UITabBarItem(title: L10n.trackersTabBarItemTitle, image: Asset.Images.trackersTabBarImage.image, tag: 1)
        // Создание вью контроллера для экрана со статистикой
        let statisticsViewPresenter = StatisticsViewPresenter()
        let statisticsViewController = StatisticsViewController(withPresenter: statisticsViewPresenter)
        statisticsViewController.tabBarItem = UITabBarItem(title: L10n.statisticsTabBarItemTitle, image: Asset.Images.statisticsTabBarImage.image, tag: 2)
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
        return tabBarController
    }
}
