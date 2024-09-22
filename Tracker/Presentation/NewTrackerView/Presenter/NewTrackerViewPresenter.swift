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
        case trackerTypeNotDefined
    }

    enum Constants {
        static let trackerButtonCellCategoryTitle = L10n.trackerButtonCellCategoryTitle
        static let trackerButtonCellScheduleTitle = L10n.trackerButtonCellScheduleTitle
        static let everyDayTitle = L10n.everyDayTitle
        static let monadyShortening = L10n.monadyShortening
        static let tuesdayShortening = L10n.tuesdayShortening
        static let wednesdayShortening = L10n.wednesdayShortening
        static let thursdayShortening = L10n.thursdayShortening
        static let fridayShortening = L10n.fridayShortening
        static let saturdayShortening = L10n.saturdayShortening
        static let sundayShortening = L10n.sundayShortening
    }

    // MARK: - Constants

    /// Массив с доступными для выбора пользователем эмоджи трекера
    let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]

    let colors = {
        var colors: [UIColor] = []
        colors.append(Asset.Colors.ColorSections.appColorSection1.color)
        colors.append(Asset.Colors.ColorSections.appColorSection2.color)
        colors.append(Asset.Colors.ColorSections.appColorSection3.color)
        colors.append(Asset.Colors.ColorSections.appColorSection4.color)
        colors.append(Asset.Colors.ColorSections.appColorSection5.color)
        colors.append(Asset.Colors.ColorSections.appColorSection6.color)
        colors.append(Asset.Colors.ColorSections.appColorSection7.color)
        colors.append(Asset.Colors.ColorSections.appColorSection8.color)
        colors.append(Asset.Colors.ColorSections.appColorSection9.color)
        colors.append(Asset.Colors.ColorSections.appColorSection10.color)
        colors.append(Asset.Colors.ColorSections.appColorSection11.color)
        colors.append(Asset.Colors.ColorSections.appColorSection12.color)
        colors.append(Asset.Colors.ColorSections.appColorSection13.color)
        colors.append(Asset.Colors.ColorSections.appColorSection14.color)
        colors.append(Asset.Colors.ColorSections.appColorSection15.color)
        colors.append(Asset.Colors.ColorSections.appColorSection16.color)
        colors.append(Asset.Colors.ColorSections.appColorSection17.color)
        colors.append(Asset.Colors.ColorSections.appColorSection18.color)
        return colors
    }()
    let trackerRecordStore = TrackerRecordStore.shared

    // MARK: - Public Properties

    /// Ассоциированный вью контроллер
    weak var viewController: NewTrackerViewPresenterDelegate?
    weak var delegate: AddTrackerViewPresenterDelegate?

    // MARK: - Private Properties
    /// Тип трекера
    private(set) var trackerType: TrackerType? {
        didSet {
            guard
                let trackerType = trackerType,
                let viewController = viewController
            else { return }
            viewController.setupViewsWithTrackerType(trackerType: trackerType)
        }
    }
    /// Выбранная категория трекера
    private var categoryName: String?
    /// Идентификатор трекера
    private var trackerId: UUID?
    /// Наименование трекера
    private var trackerName: String?
    /// Выбранное расписание трекера
    private var schedule: Week = []
    /// Выбранный эмоджи для трекера
    private var emoji: String?
    /// Выбранный цвет трекера
    private var color: UIColor?
    /// Признак закреплённого трекера
    private var isFixed: Bool = false

    // MARK: - Public Methods

    func canSaveTracker() -> Bool {
        guard
            let trackerType = trackerType,
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
            cell.configureButton(title: Constants.trackerButtonCellCategoryTitle, subTitle: categoryName)
        } else {
            cell.configureButton(title: Constants.trackerButtonCellScheduleTitle, subTitle: getTrackerScheduleTitle())
        }
    }

    func processCategory(_ categoryName: String) {
        self.categoryName = categoryName
        configureCreateButton()
        viewController?.updateButtonsPanel()
    }

    func processColor(_ color: UIColor) {
        self.color = color
        configureCreateButton()
    }

    func processEmoji(_ emoji: String) {
        self.emoji = emoji
        configureCreateButton()
    }

    func processName(_ trackerName: String?) {
        self.trackerName = trackerName
        guard let textLength = trackerName?.count else { return }
        if textLength > 38 {
            viewController?.showTrackersNameViolation()
        } else {
            viewController?.hideTrackersNameViolation()
        }
        configureCreateButton()
    }

    func processSchedule(_ schedule: Week) {
        self.schedule = schedule
        configureCreateButton()
        viewController?.updateButtonsPanel()
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
            guard let trackerType = trackerType else {
                completion(.failure(NewTrackerErrors.trackerTypeNotDefined))
                return
            }
            completion(.success(()))
            delegate?.trackerDidRecorded(
                tracker: Tracker(
                    trackerType: trackerType,
                    categoryName: categoryName ?? "",
                    id: trackerId ?? UUID(),
                    name: trackerName ?? "",
                    color: color ?? UIColor(),
                    emoji: emoji ?? "",
                    schedule: schedule,
                    isFixed: isFixed
                )
            )
        }
    }

    func showCategories() {
        guard let viewController = viewController as? UIViewController else { return }
        let targetViewController = CategoriesScreenAssembley.build(withDelegate: self, withCategory: categoryName)
        let router = Router(viewController: viewController, targetViewController: targetViewController)
        router.showNext(dismissCurrent: false)
    }

    func showTrackerSchedule() {
        guard let viewController = viewController as? UIViewController else { return }
        let targetViewController = ScheduleScreenAssembley.build(withDelegate: self, forSchedule: schedule)
        let router = Router(viewController: viewController, targetViewController: targetViewController)
        router.showNext(dismissCurrent: false)
    }

    func startCreating(trackerType: TrackerType) {
        self.trackerType = trackerType
        switch trackerType {
        case.habit:
            viewController?.setViewControllerTitle(L10n.viewTitleForCreateHabit)
        case .event:
            viewController?.setViewControllerTitle(L10n.viewTitleForCreateEvent)
        }
        viewController?.setSaveButtonTitle(L10n.trackerSaveButtonForCreatingTitle)
    }

    func startEditing(tracker: Tracker) {
        self.trackerType = tracker.trackerType
        switch tracker.trackerType {
        case .habit:
            viewController?.setViewControllerTitle(L10n.viewTitleForEditHabit)
            let trackerDaysCount = trackerRecordStore.trackersRecordCount(withId: tracker.id)
            viewController?.setTrackerRepeatsCountTitle(DaysFormatter.shared.daysToStringWithSuffix(Double(trackerDaysCount)))
        case .event:
            viewController?.setViewControllerTitle(L10n.viewTitleForEditEvent)
        }
        viewController?.setSaveButtonTitle(L10n.trackerSaveButtonForEditingTitle)

        processCategory(tracker.categoryName)

        trackerId = tracker.id

        viewController?.setTrackerName(tracker.name)
        processName(tracker.name)

        processSchedule(tracker.schedule)

        if let emojiIndex = emojies.firstIndex(of: tracker.emoji) {
            let indexPath = IndexPath(row: emojiIndex, section: 0)
            viewController?.setEmoji(at: indexPath)
            processEmoji(tracker.emoji)
        }

        if let colorIndex = colors.firstIndex(of: tracker.color) {
            let indexPath = IndexPath(row: colorIndex, section: 0)
            viewController?.setColor(at: indexPath)
            processColor(tracker.color)
        }

        isFixed = tracker.isFixed
    }

    // MARK: - Private Methods

    /// Используется для установки внешнего вида кнопки "Создать" в зависимости от полноты и корректности заполнения реквизитов трекера
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
        if schedule.count == 7 { return Constants.everyDayTitle }

        var scheduleTitle = ""
        if schedule.contains(.monday) { scheduleTitle += Constants.monadyShortening + ", " }
        if schedule.contains(.tuesday) { scheduleTitle += Constants.tuesdayShortening + ", " }
        if schedule.contains(.wednesday) { scheduleTitle += Constants.wednesdayShortening + ", " }
        if schedule.contains(.thursday) { scheduleTitle += Constants.thursdayShortening + ", " }
        if schedule.contains(.friday) { scheduleTitle += Constants.fridayShortening + ", " }
        if schedule.contains(.saturday) { scheduleTitle += Constants.saturdayShortening + ", " }
        if schedule.contains(.sunday) { scheduleTitle += Constants.sundayShortening + ", " }

        return String(scheduleTitle.dropLast(2))
    }
}
