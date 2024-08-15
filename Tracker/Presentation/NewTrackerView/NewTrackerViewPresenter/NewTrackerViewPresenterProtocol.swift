//
//  NewTrackerViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

protocol NewTrackerViewPresenterProtocol: AnyObject, UITableViewDataSource, UITableViewDelegate {
    /// Ассоциированный вью контроллер
    var viewController: NewTrackerViewPresenterDelegate? { get set }
    /// Используется для проверки заполнения обязательных для сохранения трекера реквизитов
    /// - Returns: истина, если обязательные реквизиты заполнены и трекер может быть создан; ложь - в противном случае
    func canSaveTracker() -> Bool
    /// Обработчик наименования трекера
    /// - Parameter trackerName: текущее наименование трекера
    func processTrackersName(_ trackerName: String?)
    /// Сохраняет трекер
    /// - Parameter completion: обработчик, вызываемый по завершении сохранения трекера
    func saveTracker(_ completion: @escaping (Result<Void, Error>) -> Void)
    /// Обновляет расписание трекера
    /// - Parameter schedule: актуальное расписание запуска трекера
    func updateTrackerSchedule(with schedule: Set<Weekday>)
}
