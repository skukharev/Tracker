//
//  ScreenshotTests.swift
//  ScreenshotTests
//
//  Created by Сергей Кухарев on 24.09.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class ScreenshotTests: XCTestCase {
    func testTrackersViewLight() throws {
        let viewController = TrackersViewScreenAssembley.build()
        assertSnapshots(of: viewController, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }

    func testTrackersViewDark() throws {
        let viewController = TrackersViewScreenAssembley.build()
        assertSnapshots(of: viewController, as: [.image(traits: .init(userInterfaceStyle: .dark))])
    }
}

enum TrackersViewScreenAssembley {
    static func build() -> UIViewController {
        let trackersViewPresenter = TrackersViewPresenterSpy()
        let trackersViewController = TrackersViewController(withPresenter: trackersViewPresenter)
        trackersViewController.tabBarItem = UITabBarItem(title: L10n.trackersTabBarItemTitle, image: Asset.Images.trackersTabBarImage.image, tag: 1)
        // Создание вью контроллера для экрана со статистикой
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: L10n.statisticsTabBarItemTitle, image: Asset.Images.statisticsTabBarImage.image, tag: 2)
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

final class TrackersViewPresenterSpy: TrackersViewPresenterProtocol {
    var viewController: TrackersViewPresenterDelegate?

    var currentDate = Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 24)) ?? Date()

    var trackersSearchFilter: String?

    var trackersFilter: TrackersFilter = .allTrackers

    func addTracker() {}

    func deleteTracker(at indexPath: IndexPath, _ completion: @escaping (Result<Void, any Error>) -> Void) {}

    func editTracker(at indexPath: IndexPath, _ completion: @escaping (Result<Void, any Error>) -> Void) {}

    func getPinnedTrackerMenuText(at indexPath: IndexPath) -> String {
        return ""
    }

    func recordTracker(for indexPath: IndexPath, _ completion: @escaping (Result<Void, any Error>) -> Void) {}

    func showCell(for cell: TrackersCollectionViewCell, with indexPath: IndexPath) {
        let cellViewModel = TrackersCellViewModel(
            emoji: "🙂",
            color: UIColor.red,
            name: "Трекер",
            daysCount: 0,
            isCompleted: false
        )
        cell.showCellViewModel(cellViewModel)
    }

    func showHeader(for header: TrackersCollectionHeaderView, with indexPath: IndexPath) {
        header.setSectionHeaderTitle("Категория")
    }

    func showTrackersFilters() {}

    func toggleFixTracker(at indexPath: IndexPath, _ completion: @escaping (Result<Void, any Error>) -> Void) {}

    func trackerCategoriesCount() -> Int {
        return 1
    }

    func trackersCount(inSection section: Int) -> Int {
        return 1
    }
}
