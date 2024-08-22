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

    // MARK: - Constants

    /// Массив с доступными для выбора пользователем эмоджи трекера
    let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]

    let colors = {
        var colors: [UIColor] = []
        for i in 1...18 {
            colors.append(UIColor(named: "App Color Section " + i.intToString) ?? .appColorSection1)
        }
        return colors
    }()

    // MARK: - Public Properties

    /// Ассоциированный вью контроллер
    weak var viewController: NewTrackerViewPresenterDelegate?
    weak var delegate: AddTrackerViewPresenterDelegate?

    // MARK: - Private Properties

    /// Выбранная категория трекера
    private var categoryName: String? = "Важное"
    /// Наименование трекера
    private var trackerName: String?
    /// Выбранное расписание трекера
    private var schedule: Week = []
    /// Выбранный эмоджи для трекера
    private var emoji: String?
    /// Выбранный цвет трекера
    private var color: UIColor?

    // MARK: - Public Methods

    func canSaveTracker() -> Bool {
        guard
            let trackerType = viewController?.trackerType,
            let categoryName = categoryName,
            let trackerName = trackerName,
            let emoji = emoji,
            color != nil
        else {
            return false
        }
        let trackerCategoryIsCorrect = !categoryName.isEmpty
        let trackerNameIsCorrect = !trackerName.isEmpty && trackerName.count < 38
        let trackerEmojiIsCorrect = !emoji.isEmpty
        switch trackerType {
        case .habit:
            let trackerscheduleIsCorrect = !schedule.isEmpty
            if  trackerCategoryIsCorrect && trackerNameIsCorrect && trackerscheduleIsCorrect && trackerEmojiIsCorrect { return true }
        case .event:
            if trackerCategoryIsCorrect && trackerNameIsCorrect && trackerEmojiIsCorrect { return true }
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

    func processColor(_ color: UIColor) {
        self.color = color
        configureCreateButton()
    }

    func processEmoji(_ emoji: String) {
        self.emoji = emoji
        configureCreateButton()
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

    func showColorCell(for cell: NewTrackerColorCell, at indexPath: IndexPath, withSelection selection: Bool) {
        guard let color = colors[safe: indexPath.row] else {
            assertionFailure("Критическая ошибка доступа к данным массива с цветами трекеров: искомый объект не найден по индексу цвета \(indexPath.row)")
            return
        }
        let cellViewModel = NewTrackerColorCellModel(color: color, isSelected: selection)
        cell.showCellViewModel(cellViewModel)
    }

    func showEmojiCell(for cell: NewTrackerEmojiCell, at indexPath: IndexPath, withSelection selection: Bool = false) {
        guard
            let emoji = emojies[safe: indexPath.row] else {
            assertionFailure("Критическая ошибка доступа к данным массива эмоджи: искомый объект не найден по индексу эмоджи \(indexPath.row)")
            return
        }
        let cellViewModel = NewTrackerEmojiCellModel(emoji: emoji, isSelected: selection)
        cell.showCellViewModel(cellViewModel)
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
                    color: color ?? UIColor(),
                    emoji: emoji ?? "",
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

    /// Используется для формирования текстового описания повторений трекера
    /// - Returns: текстовое описание дней повторения трекера
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
