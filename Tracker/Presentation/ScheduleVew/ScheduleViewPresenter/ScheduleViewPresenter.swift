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

    // MARK: - Private Properties

    private var schedule: Set<Weekday> = []

    // MARK: - Public Methods

    func needSaveSchedule() {
        delegate?.updateTrackerSchedule(with: schedule)
    }

    func showTrackerSchedule(with schedule: Set<Weekday>, on viewController: UIViewController, by delegate: NewTrackerViewPresenterProtocol) {
        self.schedule = schedule
        self.delegate = delegate
        let scheduleVewController = ScheduleViewController()
        scheduleVewController.configure(self)
        viewController.present(scheduleVewController, animated: true)
    }

    /// Возвращает количество ячеек на панели с расписанием повторения трекера
    /// - Parameters:
    ///   - tableView: табличное представление с расписанием
    ///   - section: индекс секции, для которой запрашивается количество ячеек
    /// - Returns: Количество кнопок на панели
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    /// Используется для определения ячейки, которую требуется отобразить в заданной позиции расписания
    /// - Parameters:
    ///   - tableView: табличное представление с расписанием
    ///   - indexPath: индекс отображаемой ячейки
    /// - Returns: сконфигурированную и готовую к показу кнопку
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.Constants.identifier, for: indexPath)
        guard let scheduleCell = cell as? ScheduleCell else {
            print(#fileID, #function, #line, "Ошибка приведения типов")
            return UITableViewCell()
        }
        configureScheduleCell(for: scheduleCell, with: indexPath)
        scheduleCell.delegate = self
        return scheduleCell
    }

    // MARK: - Private Methods

    private func configureScheduleCell(for cell: ScheduleCell, with indexPath: IndexPath) {
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
