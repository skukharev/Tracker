//
//  TrackerScheduleViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 15.08.2024.
//

import UIKit

final class ScheduleViewPresenter: NSObject, ScheduleViewPresenterProtocol {
    // MARK: - Public Properties

    weak var viewController: ScheduleViewPresenterDelegate?

    weak var delegate: NewTrackerViewPresenterProtocol?

    var schedule: Week = []

    // MARK: - Public Methods

    func needSaveSchedule() {
        delegate?.processSchedule(schedule)
    }

    func configureScheduleCell(for cell: ScheduleCell, with indexPath: IndexPath) {
        guard let weekDay = Weekday(rawValue: indexPath.row) else { return }
        let isSelected = schedule.contains(weekDay)
        cell.showCellViewModel(ScheduleCellModel(weekDay: weekDay, isSelected: isSelected))
    }
}

// MARK: - ScheduleCellDelegate

extension ScheduleViewPresenter: ScheduleCellDelegate {
    func weekDayScheduleChange(weekDay: Weekday, isSelected: Bool) {
        if isSelected {
            schedule.insert(weekDay)
        } else {
            schedule.remove(weekDay)
        }
    }
}
