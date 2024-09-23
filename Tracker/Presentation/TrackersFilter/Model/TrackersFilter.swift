//
//  TrackersFilter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.09.2024.
//

enum TrackersFilter: Int, CaseIterable {
    case allTrackers = 0
    case currentDayTrackers
    case complitedTrackers
    case notComplitedTrackers
}
