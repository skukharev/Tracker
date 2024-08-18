//
//  NewTrackerViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

final class NewTrackerViewPresenter: NewTrackerViewPresenterProtocol {
    // MARK: - Types

    enum NewTrackerErrors: Error {
        case canNotSaveTracker
    }

    // MARK: - Public Properties

    weak var viewController: NewTrackerViewPresenterDelegate?
    weak var delegate: AddTrackerViewPresenterDelegate?

    // MARK: - Private Properties

    /// Выбранная категория трекера
    private var categoryName: String? = "Важное"
    /// Наименование трекера
    private var trackerName: String?
    /// Выбранное расписание трекера
    private var schedule: Week = []

    // MARK: - Public Methods

    func canSaveTracker() -> Bool {
        guard
            let trackerType = viewController?.trackerType,
            let categoryName = categoryName,
            let trackerName = trackerName
        else {
            return false
        }
        let trackerCategoryIsCorrect = !categoryName.isEmpty
        let trackerNameIsCorrect = !trackerName.isEmpty && trackerName.count < 38
        switch trackerType {
        case .habit:
            let trackerscheduleIsCorrect = !schedule.isEmpty
            if  trackerCategoryIsCorrect && trackerNameIsCorrect && trackerscheduleIsCorrect { return true }
        case .event:
            if trackerCategoryIsCorrect && trackerNameIsCorrect { return true }
        }
        return false
    }

    func configureTrackerButtonCell(_ tableView: UITableView, for cell: TrackerButtonsCell, with indexPath: IndexPath) {
        if indexPath == tableView.lastCellIndexPath {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width + 1, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        cell.accessoryType = .disclosureIndicator
        if indexPath.row == 0 {
            cell.configureButton(title: "Категория", subTitle: categoryName)
        } else {
            cell.configureButton(title: "Расписание", subTitle: getTrackerScheduleTitle())
        }
    }

    func processTrackersName(_ trackerName: String?) {
        self.trackerName = trackerName
        guard let textLength = trackerName?.count else { return }
        if textLength > 38 {
            viewController?.showTrackersNameViolation()
        } else {
            viewController?.hideTrackersNameViolation()
        }
        configureCreateButton()
    }

    func saveTracker(_ completion: @escaping (Result<Void, any Error>) -> Void) {
        if !canSaveTracker() {
            completion(.failure(NewTrackerErrors.canNotSaveTracker))
        } else {
            completion(.success(()))
            delegate?.trackerDidRecorded(
                trackerCategory: categoryName ?? "",
                tracker: Tracker(
                    id: UUID(),
                    name: trackerName ?? "",
                    color: .appColorSection1,
                    emoji: "👍",
                    schedule: schedule
                )
            )
        }
    }

    func showTrackerSchedule() {
        guard let viewController = viewController as? UIViewController else { return }
        let targetViewController = ScheduleScreenAssembley.build(withDelegate: self, forSchedule: schedule)
        let router = Router(viewController: viewController, targetViewController: targetViewController)
        router.showNext(dismissCurrent: false)
    }

    func updateTrackerSchedule(with schedule: Week) {
        self.schedule = schedule
        configureCreateButton()
        viewController?.updateButtonsPanel()
    }

    // MARK: - Private Methods

    /// Используется для установки внешнего вида кнопки "Создать" в зависимости от полноти и корректности заполнения реквизитов трекера
    private func configureCreateButton() {
        if canSaveTracker() {
            viewController?.setCreateButtonEnable()
        } else {
            viewController?.setCreateButtonDisable()
        }
    }

    private func getTrackerScheduleTitle() -> String? {
        if schedule.isEmpty { return nil }
        if schedule.count == 7 { return "Каждый день" }

        var scheduleTitle = ""
        if schedule.contains(.monday) { scheduleTitle += "Пн, " }
        if schedule.contains(.tuesday) { scheduleTitle += "Вт, " }
        if schedule.contains(.wednesday) { scheduleTitle += "Ср, " }
        if schedule.contains(.thursday) { scheduleTitle += "Чт, " }
        if schedule.contains(.friday) { scheduleTitle += "Пт, " }
        if schedule.contains(.saturday) { scheduleTitle += "Сб, " }
        if schedule.contains(.sunday) { scheduleTitle += "Вс, " }

        return String(scheduleTitle.dropLast(2))
    }
}
