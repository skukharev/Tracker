//
//  NewTrackerViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

final class NewTrackerViewPresenter: NSObject, NewTrackerViewPresenterProtocol {
    // MARK: - Types

    // MARK: - Constants

    // MARK: - Public Properties

    weak var viewController: NewTrackerViewPresenterDelegate?

    // MARK: - IBOutlet

    // MARK: - Private Properties

    // MARK: - Initializers

    // MARK: - UIViewController(\*)

    // MARK: - Public Methods

    /// Возвращает количество кнопокна панели кнопок экрана редактирования трекера
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
            print("Нажата кнопка Расписание")
        }
    }

    // MARK: - Private Methods

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
            cell.configureButton(title: "Категория")
        } else {
            cell.configureButton(title: "Расписание")
        }
    }
}
