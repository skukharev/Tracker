//
//  NewTrackerViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

protocol NewTrackerViewPresenterProtocol: AnyObject {
    /// Ассоциированный вью контроллер
    var viewController: NewTrackerViewPresenterDelegate? { get set }
    /// Список доступных к выбору эмоджи
    var emojies: [String] { get }
    /// Список доступных к выбору цветов трекера
    var colors: [UIColor] { get }
    /// Используется для проверки заполнения обязательных для сохранения трекера реквизитов
    /// - Returns: истина, если обязательные реквизиты заполнены и трекер может быть создан; ложь - в противном случае
    func canSaveTracker() -> Bool
    /// Используется для конфигурирования и отображения заданной кнопки панели кнопок
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - cell: Отображаемая кнопка
    ///   - indexPath: индекс отображаемой кнопки
    func configureTrackerButtonCell(_ tableView: UITableView, for cell: TrackerButtonsCell, with indexPath: IndexPath)
    /// Обработчик выбранного пользователем цвета трекера
    /// - Parameter color: выбранный цвет
    func processColor(_ color: UIColor)
    /// Обработчик выбранного пользователем эмоджи трекера
    /// - Parameter emoji: символ эмоджи
    func processEmoji(_ emoji: String)
    /// Обработчик наименования трекера
    /// - Parameter trackerName: текущее наименование трекера
    func processTrackersName(_ trackerName: String?)
    /// Сохраняет трекер
    /// - Parameter completion: обработчик, вызываемый по завершении сохранения трекера
    func saveTracker(_ completion: @escaping (Result<Void, Error>) -> Void)
    /// Конфигурирует ячейку с эмоджи для её отображения в коллекции
    /// - Parameters:
    ///   - cell: Объект-ячейка
    ///   - indexPath: Индекс ячейки внутри коллекции
    ///   - selection: Признак отображения выделения ячейки
    func showEmojiCell(for cell: NewTrackerEmojiCell, at indexPath: IndexPath, withSelection selection: Bool)
    /// Конфигурирует ячейку с цветом трекера для её отображения в коллекции
    /// - Parameters:
    ///   - cell: Объект-ячейка
    ///   - indexPath: Индекс ячейки внутри коллекции
    ///   - selection: Признак отображения выделения ячейки
    func showColorCell(for cell: NewTrackerColorCell, at indexPath: IndexPath, withSelection selection: Bool)
    /// Отображает экран с выбором расписания повторения трекера
    func showTrackerSchedule()
    /// Отображает экран выбора категории трекера
    func showCategories()
    /// Обновляет расписание трекера
    /// - Parameter schedule: актуальное расписание запуска трекера
    func updateTrackerSchedule(with schedule: Week)
    /// Обновляет категорию трекера
    /// - Parameter category: актуальное наименование категории трекера
    func updateTrackerCategory(with categoryName: String)
}
