//
//  StatisticsType.swift
//  Tracker
//
//  Created by Сергей Кухарев on 24.09.2024.
//

import Foundation

enum StatisticsType: CustomStringConvertible {
    case completedTrackers
    case averageTrackers
    case idealDaysCount

    var description: String {
        switch self {
        case .completedTrackers:
            return L10n.statisticsTypeCompleted
        case .averageTrackers:
            return L10n.statisticsTypeAverage
        case .idealDaysCount:
            return L10n.statisticsTypeIdealDaysCount
        }
    }
}
