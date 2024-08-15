//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import UIKit

final class TrackersViewPresenter: NSObject, TrackersViewPresenterProtocol {
    // MARK: - Types

    enum TrackersViewPresenterErrors: Error {
        case trackerNotFound
        case trackerCompletionInTheFutureIsProhibited
    }

    // MARK: - Constants

    let trackersCellParams = UICollectionViewCellGeometricParams(cellCount: 2, topInset: 0, leftInset: 0, rightInset: 0, bottomInset: 0, cellSpacing: 9, cellHeight: 148, lineSpacing: 10)

    // MARK: - Public Properties

    weak var viewController: TrackersViewPresenterDelegate?

    /// Дата, на которую отображается коллекция трекеров
    public var currentDate: Date {
        get {
            return trackersDate
        }
        set {
            trackersDate = newValue.removeTimeStamp
            loadTrackers()
        }
    }

    // MARK: - Private Properties

    /// Переменная для хранения значения currentDate
    private var trackersDate = Date()
    /// Список категорий и вложенных в них трекеров
    private var categoriesDatabase: [TrackerCategory] = []
    /// Список категорий и вложенных в них трекеров на текущую дату
    private var categoriesOnDate: [TrackerCategory] = []
    /// Список выполненных трекеров
    private var completedTrackers: Set<TrackerRecord> = []

    // MARK: - Public Methods

    func addTracker(_ completion: @escaping (AddTrackerViewPresenterDelegate) -> Void) {
        let addTrackerViewController = AddTrackerViewController()
        let addTrackerViewPresenter = AddTrackerViewPresenter()
        addTrackerViewController.configure(addTrackerViewPresenter)
        addTrackerViewPresenter.delegate = self
        completion(addTrackerViewController)
    }

    func recordTracker(for indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard
            let category = categoriesOnDate[safe: indexPath.section],
            let tracker = category.trackers[safe: indexPath.row]
        else {
            assertionFailure("Критическая ошибка доступа к данным трекеров - искомые категория и/или трекер не найдены")
            completion(.failure(TrackersViewPresenterErrors.trackerNotFound))
            return
        }

        if currentDate > Date().removeTimeStamp {
            completion(.failure(TrackersViewPresenterErrors.trackerCompletionInTheFutureIsProhibited))
            return
        }

        if let trackerRecord = completedTrackers.first(where: {
            $0.trackerId == tracker.id && $0.recordDate == currentDate
        }) {
            completedTrackers.remove(trackerRecord)
        } else {
            completedTrackers.insert(TrackerRecord(trackerId: tracker.id, recordDate: currentDate))
        }
        completion(.success(()))
    }

    /// Конифугрирует ячейку для её отображения в коллекции
    /// - Parameters:
    ///   - cell: Объект-ячейка
    ///   - indexPath: Индекс ячейки внутри коллекции
    func showCell(for cell: TrackersCollectionViewCell, with indexPath: IndexPath) {
        guard
            let category = categoriesOnDate[safe: indexPath.section],
            let tracker = category.trackers[safe: indexPath.row] else {
            assertionFailure("Критическая ошибка доступа к данным трекера: искомый объект не найден по индексу секции \(indexPath.section) и индексу трекера \(indexPath.row)s")
            return
        }
        let cellViewModel = TrackersCellViewModel(
            emoji: tracker.emoji,
            color: tracker.color,
            name: tracker.name,
            daysCount: trackersRecordCount(withId: tracker.id),
            isCompleted: isTrackerCompleted(withId: tracker.id)
        )
        cell.showCellViewModel(cellViewModel)
    }

    /// Конфигурирует заголовок секции для его отображения
    /// - Parameters:
    ///   - header: Объект-заголовок
    ///   - indexPath: ИНдекс заголовка внутри коллекции
    private func showHeader(for header: TrackersCollectionHeaderView, with indexPath: IndexPath) {
        guard let category = categoriesOnDate[safe: indexPath.section] else {
            assertionFailure("Критическая ошибка доступа к данным трекера: искомая категория трекеров не найдена по индексу секции \(indexPath.section)")
            return
        }
        header.setSectionHeaderTitle(category.categoryName)
    }

    func trackerDidRecorded(trackerCategory: String, tracker: Tracker) {
        var tmpCategories = categoriesDatabase
        if let categoryIndex = tmpCategories.firstIndex(where: {
            $0.categoryName.lowercased() == trackerCategory.lowercased()
        }) {
            var trackers = tmpCategories[categoryIndex].trackers
            trackers.append(tracker)
            tmpCategories[categoryIndex] = TrackerCategory(categoryName: tmpCategories[categoryIndex].categoryName, trackers: trackers)
        } else {
            tmpCategories.append(TrackerCategory(categoryName: trackerCategory, trackers: [tracker]))
        }
        categoriesDatabase = tmpCategories
        loadTrackers()
    }

    // MARK: - Private Methods

    /// Используется для определения факта выполнения заданного трекера на текущую дату
    /// - Parameter id: Идентификатор трекера
    /// - Returns: Возвращает истину, если трекер был выполнен на текущую дату; ложь - в противном случае
    private func isTrackerCompleted(withId id: UUID) -> Bool {
        return completedTrackers.contains {
            $0.trackerId == id && $0.recordDate == currentDate
        }
    }

    /// Загружает трекеры из базы данных
    private func loadTrackers() {
        guard let dayOfTheWeek = Weekday.dayOfTheWeek(of: currentDate) else {
            assertionFailure("Ошибка определения дня недели на основании текущей даты")
            return
        }

        categoriesOnDate = []
        categoriesDatabase.forEach { category in
            let trackersOnDate = category.trackers.filter { tracker in
                if tracker.schedule.contains(dayOfTheWeek) {
                    return true
                } else {
                    if tracker.schedule.isEmpty {
                        if trackersRecordCount(withId: tracker.id) == 0 {
                            return true
                        } else {
                            guard
                                let trackerRecord = completedTrackers.first(where: { $0.trackerId == tracker.id })
                            else {
                                return false
                            }
                            if trackerRecord.recordDate == currentDate {
                                return true
                            } else {
                                return false
                            }
                        }
                    } else {
                        return false
                    }
                }
            }
            if !trackersOnDate.isEmpty {
                categoriesOnDate.append(TrackerCategory(categoryName: category.categoryName, trackers: trackersOnDate))
            }
        }
        if categoriesOnDate.isEmpty {
            viewController?.showTrackersListStub()
        } else {
            viewController?.showTrackersList()
        }
    }

    /// Используется для вычисления количества выполнений заданного трекера
    /// - Parameter id: Идентификатор трекера
    /// - Returns: Общее количество выполнений заданного трекера
    private func trackersRecordCount(withId id: UUID) -> Int {
        return completedTrackers.filter { $0.trackerId == id }.count
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewPresenter: UICollectionViewDataSource {
    /// Возвращает количество секций (категорий теркеров) коллекции трекеров на текущую дату
    /// - Parameter collectionView: Элемент управления
    /// - Returns: Количество секций (категорий трекеров)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categoriesOnDate.count
    }

    /// Возвращает количество ячеек (трекеров) в заданной секции (категории трекеров) на текущую дату
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - section: Индекс секции в коллекции
    /// - Returns: Количество ячеек (трекеров) в заданной секции (категории трекеров)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let trackersCount = categoriesOnDate[safe: section]?.trackers.count else { return 0 }
        return trackersCount
    }

    /// Используется для визуального оформления заголовка секции коллекции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - kind: Тип: заголовок/футер
    ///   - indexPath: Индекс заголовка секции в коллекции
    /// - Returns: Сконфигурированная и готовый к отображению заголовок коллекции трекеров
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = TrackersCollectionHeaderView.Constants.identifier
        default:
            id = ""
        }

        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersCollectionHeaderView else {
            assertionFailure("Элемент управления заголовком секции трекеров не найден")
            return UICollectionReusableView()
        }
        showHeader(for: view, with: indexPath)
        return view
    }

    /// Используется для визуального оформления ячейки коллекции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - indexPath: Индекс ячейки в коллекции трекеров
    /// - Returns: Сконфигурированная и готовая к отображению ячейка коллекции трекеров
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCollectionViewCell.Constants.identifier,
            for: indexPath) as? TrackersCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.delegate = viewController as? TrackersCollectionViewCellDelegate
        showCell(for: cell, with: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewPresenter: UICollectionViewDelegateFlowLayout {
    /// Задаёт размеры отображаемой ячейки в коллекции трекеров
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - indexPath: Индекс ячейки в коллекции трекеров
    /// - Returns: Размер ячейки с трекером
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - trackersCellParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(trackersCellParams.cellCount)
        return CGSize(width: cellWidth, height: trackersCellParams.cellHeight)
    }

    /// Задаёт размеры отступов ячеек заданной секции (категории трекеров) от границ коллекции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размеры отступов ячеек секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: trackersCellParams.topInset, left: trackersCellParams.leftInset, bottom: trackersCellParams.bottomInset, right: trackersCellParams.rightInset)
    }

    /// Задаёт размеры отступов между строками ячеек заданной секции (категории трекеров)
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размер отступа между строками ячеек заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return trackersCellParams.lineSpacing
    }

    /// Задаёт размер отступов между ячейками одной строки заданной секции (категории трекеров)
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размер отступа между ячейками одной строки заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return trackersCellParams.cellSpacing
    }

    /// Задаёт размер заголовка секции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размер заголовка секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)

        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        let headerSize = headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return headerSize
    }
}
