//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

final class TrackersViewPresenter: TrackersViewPresenterProtocol {
    // MARK: - Types

    // MARK: - Constants

    // MARK: - Public Properties

    weak var viewController: (any TrackersViewPresenterDelegate)?

    public var currentDate: Date {
        get {
            return trackersDate
        }
        set {
            trackersDate = newValue
            loadTrackers()
        }
    }

    // MARK: - IBOutlet

    // MARK: - Private Properties

    /// Перемення для хранения значения currentDate
    private var trackersDate = Date()
    /// Список категорий и вложенных в них трекеров
    private var categories: [TrackerCategory] = [
        TrackerCategory(
            categoryName: "Домашний уют",
            trackers: [
                Tracker(
                    id: UUID(
                        uuidString: "c35b5998-ee09-497d-a17e-0da346a199b6"
                    ) ?? UUID(),
                    name: "Поливать растения",
                    color: .appColorSection1,
                    emoji: "❤️",
                    schedule: [.tuesday, .wednesday]
                )
            ]
        )
    ]
    /// Список выполненных трекеров
    private var completedTrackers: Set<TrackerRecord> = []

    // MARK: - Initializers

    // MARK: - Public Methods

    /// Загружает трекеры из базы данных
    func loadTrackers() {
        if trackersCount() == 0 {
            viewController?.showTrackersListStub()
        } else {
            viewController?.showTrackersList()
        }
    }

    func trackersCount() -> Int {
        let currentWeekDay = Calendar.current.component(.weekday, from: currentDate) - Calendar.current.firstWeekday
        guard let dayOfTheWeek = Schedule(rawValue: currentWeekDay) else {
            assertionFailure("Невозможно произвести мэппинг порядкового дня недели в значение перечисления Schedule")
            return 0
        }
        return categories.reduce(into: 0) {
            if !$1.trackers.filter( {
                $0.schedule.contains(dayOfTheWeek)
            }).isEmpty {
                $0 += 1
            }
        }
    }

    // MARK: - Private Methods

}
