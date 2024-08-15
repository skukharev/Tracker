//
//  TrackersViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import UIKit


protocol TrackersViewPresenterProtocol: AnyObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// Ассоциированный вью контроллер
    var viewController: TrackersViewPresenterDelegate? { get set }
    /// Текущая дата трекеров
    var currentDate: Date { get set }
    /// Добавляет трекер
    /// - Parameter completion: Замыкание, вызываемое после завершения конфигурирования вью контроллера для его отображения на экране
    func addTracker(_ completion: @escaping (AddTrackerViewPresenterDelegate) -> Void)
    /// В случае если трекер на текущую дату не выполнялся, то производит фиксацию выполнения трекера; и удаляет фиксацию выполнения трекера в противном случае
    /// - Parameters:
    ///   - for: Индекс трекера в коллекции трекеров
    ///   - completion: Обработчик, вызываемый по окончании выполнения метода, возвращает истину в случае фиксации выполнения трекера, возвращает ложь в случае если фиксация выполнения трекера была удалена, либо ошибку при возникновении ошибок работы с данными
    func recordTracker(for indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void)
    /// Конифугрирует ячейку для её отображения в коллекции
    /// - Parameters:
    ///   - cell: Объект-ячейка
    ///   - indexPath: Индекс ячейки внутри коллекции
    func showCell(for cell: TrackersCollectionViewCell, with indexPath: IndexPath)
    /// Вызывается после успешного завершения редактирования данных трекера
    /// - Parameters:
    ///   - trackerCategory: выбранная категория трекера
    ///   - tracker: данные трекера
    func trackerDidRecorded(trackerCategory: String, tracker: Tracker)
}
