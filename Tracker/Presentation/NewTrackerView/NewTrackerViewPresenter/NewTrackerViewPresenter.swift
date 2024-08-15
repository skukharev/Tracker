//
//  NewTrackerViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

final class NewTrackerViewPresenter: NSObject, NewTrackerViewPresenterProtocol {
    // MARK: - Types

    enum NewTrackerErrors: Error {
        case canNotSaveTracker
    }

    // MARK: - Public Properties

    weak var viewController: NewTrackerViewPresenterDelegate?
    weak var delegate: TrackersViewPresenterProtocol?

    // MARK: - Private Properties

    /// Выбранная категория трекера
    private var categoryName: String? = "Важное"
    /// Наименование трекера
    private var trackerName: String?
    /// Выбранное расписание трекера
    private var schedule: Set<Weekday> = []

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

    /// Возвращает количество кнопок на панели кнопок экрана редактирования трекера
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - section: индекс секции, для которой запрашивается количество кнопок
    /// - Returns: Количество кнопок на панели
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewController = viewController else { return 0 }
        switch viewController.trackerType {
        case .none:
            return 0
        case .habit:
            return 2
        case .event:
            return 1
        }
    }

    /// Используется для определения ячейки, которую требуется отобразить в заданной позиции панели кнопок экрана редактирования трекера
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - indexPath: индекс отображаемой кнопки
    /// - Returns: сконфигурированную и готовую к показу кнопку
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackerButtonsCell.Constants.identifier, for: indexPath)
        guard let buttonsCell = cell as? TrackerButtonsCell else {
            print(#fileID, #function, #line, "Ошибка приведения типов")
            return UITableViewCell()
        }
        configureTrackerButtonCell(tableView, for: buttonsCell, with: indexPath)
        return buttonsCell
    }

    /// Обработчик выделения заданной кнопки (ячейки)
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - indexPath: индекс отображаемой кнопки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("Нажата кнопка Категория")
        } else {
            showTrackerSchedule()
        }
    }

    func updateTrackerSchedule(with schedule: Set<Weekday>) {
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

    /// Используется для конфигурирования и отображения заданной кнопки панели кнопок
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - cell: Отображаемая кнопка
    ///   - indexPath: индекс отображаемой кнопки
    private func configureTrackerButtonCell(_ tableView: UITableView, for cell: TrackerButtonsCell, with indexPath: IndexPath) {
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

    /// Отображает экран с выбором расписания повторения трекера
    private func showTrackerSchedule() {
        guard let viewController = viewController as? UIViewController else { return }
        let scheduleViewPresenter = ScheduleViewPresenter()
        scheduleViewPresenter.showTrackerSchedule(with: schedule, on: viewController, by: self)
    }
}
