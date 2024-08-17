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
    /// Используется для проверки заполнения обязательных для сохранения трекера реквизитов
    /// - Returns: истина, если обязательные реквизиты заполнены и трекер может быть создан; ложь - в противном случае
    func canSaveTracker() -> Bool
    /// Используется для конфигурирования и отображения заданной кнопки панели кнопок
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - cell: Отображаемая кнопка
    ///   - indexPath: индекс отображаемой кнопки
    func configureTrackerButtonCell(_ tableView: UITableView, for cell: TrackerButtonsCell, with indexPath: IndexPath)
    /// Обработчик наименования трекера
    /// - Parameter trackerName: текущее наименование трекера
    func processTrackersName(_ trackerName: String?)
    /// Сохраняет трекер
    /// - Parameter completion: обработчик, вызываемый по завершении сохранения трекера
    func saveTracker(_ completion: @escaping (Result<Void, Error>) -> Void)
    /// Отображает экран с выбором расписания повторения трекера
    func showTrackerSchedule()
    /// Обновляет расписание трекера
    /// - Parameter schedule: актуальное расписание запуска трекера
    func updateTrackerSchedule(with schedule: Set<Weekday>)
}
