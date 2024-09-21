//
//  NewTrackerViewController+Extensions.swift
//  Tracker
//
//  Created by Сергей Кухарев on 21.08.2024.
//

import UIKit

// MARK: - UITableViewDataSource

extension NewTrackerViewController: UITableViewDataSource {
    /// Возвращает количество кнопок на панели кнопок экрана редактирования трекера
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - section: индекс секции, для которой запрашивается количество кнопок
    /// - Returns: Количество кнопок на панели
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trackerType = presenter?.trackerType else { return 0 }
        switch trackerType {
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
        presenter?.configureTrackerButtonCell(tableView, for: buttonsCell, with: indexPath)
        return buttonsCell
    }
}

// MARK: - UITableViewDelegate

extension NewTrackerViewController: UITableViewDelegate {
    /// Обработчик выделения заданной кнопки (ячейки)
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - indexPath: индекс отображаемой кнопки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            presenter?.showCategories()
        } else {
            presenter?.showTrackerSchedule()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension NewTrackerViewController: UICollectionViewDataSource {
    /// Возвращает количество элементов в коллекциях вью контроллера
    /// - Parameters:
    ///   - collectionView: ссылка на объект-инициатор события
    ///   - section: индекс секции, для которой запрашивается количество элементов
    /// - Returns: Количество элементов коллекции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.emojiCollectionView {
            return presenter?.emojies.count ?? 0
        }
        if collectionView == self.colorsCollectionView {
            return presenter?.colors.count ?? 0
        }
        return 0
    }

    /// Используется для визуального оформления ячейки коллекции
    /// - Parameters:
    ///   - collectionView: ссылка на объект-инициатор события
    ///   - indexPath: индекс ячейки
    /// - Returns: Сконфигурированная и готовая к отображению ячейка коллекци
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewTrackerEmojiCell.Constants.identifier, for: indexPath) as? NewTrackerEmojiCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            presenter?.showEmojiCell(for: cell, at: indexPath, withSelection: false)
            return cell
        }
        if collectionView == self.colorsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewTrackerColorCell.Constants.identifier, for: indexPath) as? NewTrackerColorCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            presenter?.showColorCell(for: cell, at: indexPath, withSelection: false)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension NewTrackerViewController: UICollectionViewDelegate {
    /// Обработчик выделения ячейки
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.emojiCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerEmojiCell else { return }
            presenter?.showEmojiCell(for: cell, at: indexPath, withSelection: true)
        }
        if collectionView == self.colorsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerColorCell else { return }
            presenter?.showColorCell(for: cell, at: indexPath, withSelection: true)
        }
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
    }
    /// Обработчик снятия выделения с ячейки
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == self.emojiCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerEmojiCell else { return }
            presenter?.showEmojiCell(for: cell, at: indexPath, withSelection: false)
        }
        if collectionView == self.colorsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerColorCell else { return }
            presenter?.showColorCell(for: cell, at: indexPath, withSelection: false)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    /// Задаёт размеры отображаемой ячейки в коллекции трекеров
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - indexPath: Индекс ячейки в коллекции трекеров
    /// - Returns: Размер ячейки коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - geometricParams.collectionViewParams.paddingWidth
        let cellWidth = min(availableWidth / CGFloat(geometricParams.collectionViewParams.cellCount), geometricParams.collectionViewParams.cellWidth)
        return CGSize(width: cellWidth, height: geometricParams.collectionViewParams.cellHeight)
    }

    /// Задаёт размеры отступов ячеек заданной секции от границ коллекции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции
    /// - Returns: Размеры отступов ячеек секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: geometricParams.collectionViewParams.topInset,
            left: geometricParams.collectionViewParams.leftInset,
            bottom: geometricParams.collectionViewParams.bottomInset,
            right: geometricParams.collectionViewParams.rightInset
        )
    }

    /// Задаёт размеры отступов между строками ячеек заданной секции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции
    /// - Returns: Размер отступа между строками ячеек заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return geometricParams.collectionViewParams.lineSpacing
    }

    /// Задаёт размер отступов между ячейками одной строки заданной секции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции
    /// - Returns: Размер отступа между ячейками одной строки заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return geometricParams.collectionViewParams.cellSpacing
    }
}


// MARK: - NewTrackerEmojiCellDelegate

extension NewTrackerViewController: NewTrackerEmojiCellDelegate {
    func emojiDidChange(_ newEmoji: String) {
        presenter?.processEmoji(newEmoji)
    }
}

// MARK: - NewTrackerColorCellDelegate

extension NewTrackerViewController: NewTrackerColorCellDelegate {
    func colorDidChange(_ newColor: UIColor) {
        presenter?.processColor(newColor)
    }
}

// MARK: - UITextFieldDelegate

extension NewTrackerViewController: UITextFieldDelegate {
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
