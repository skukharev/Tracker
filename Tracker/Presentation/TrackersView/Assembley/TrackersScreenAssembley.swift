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
        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem = UITabBarItem(title: GlobalConstants.trackersTabBarItemTitle, image: UIImage(named: GlobalConstants.trackersTabBarImageName), tag: 1)
        let trackersViewPresenter = TrackersViewPresenter()
        trackersViewController.configure(trackersViewPresenter)
        // Создание вью контроллера для экрана со статистикой
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: GlobalConstants.statisticsTabBarItemTitle, image: UIImage(named: GlobalConstants.statisticsTabBarImageName), tag: 2)
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
        return tabBarController
    }
}
