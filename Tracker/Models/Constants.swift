//
//  Constants.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation
import UIKit

/// Глобальные константы проекта
enum GlobalConstants {
    static let ypBold34 = UIFont.systemFont(ofSize: 34, weight: .bold)
    static let ypBold32 = UIFont.systemFont(ofSize: 32, weight: .bold)
    static let ypBold19 = UIFont.systemFont(ofSize: 19, weight: .bold)
    static let ypRegular17 = UIFont.systemFont(ofSize: 17, weight: .regular)
    static let ypMedium16 = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let ypMedium12 = UIFont.systemFont(ofSize: 12, weight: .medium)
    static let ypMedium10 = UIFont.systemFont(ofSize: 10, weight: .medium)
    static let doneButton = UIImage(named: "DoneButton") ?? UIImage()
    static let plusButton = UIImage(systemName: "plus") ?? UIImage()
    static let onboardingPage1Image = UIImage(named: "OnboardingPage1") ?? UIImage()
    static let onboardingPage2Image = UIImage(named: "OnboardingPage2") ?? UIImage()
    static let trackersTabBarItemTitle = NSLocalizedString("trackersTabBarItemTitle", comment: "")
    static let trackersTabBarImageName = "TrackersTabBarImage"
    static let statisticsTabBarImageName = "StatisticsTabBarImage"
    static let statisticsTabBarItemTitle = NSLocalizedString("statisticsTabBarItemTitle", comment: "")
}
