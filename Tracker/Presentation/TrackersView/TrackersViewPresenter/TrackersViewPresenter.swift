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
    }

    // MARK: - Constants

    let trackersCellParams = TrackersCellGeometricParams(cellCount: 2, topInset: 0, leftInset: 0, rightInset: 0, bottomInset: 0, cellSpacing: 9, cellHeight: 148, lineSpacing: 10)

    // MARK: - Public Properties

    weak var viewController: TrackersViewPresenterDelegate?

    public var currentDate: Date {
        get {
            return trackersDate
        }
        set {
            trackersDate = newValue.removeTimeStamp
            loadTrackers()
        }
    }

    // MARK: - IBOutlet

    // MARK: - Private Properties

    /// Перемення для хранения значения currentDate
    private var trackersDate = Date()
    /// Список категорий и вложенных в них трекеров
    private var categories: [TrackerCategory] = [
        TrackerCategory(
            categoryName: "Домашний уют",
            trackers: [
                Tracker(
                    id: UUID(
                        uuidString: "c35b5998-ee09-497d-a17e-0da346a199b6"
                    ) ?? UUID(),
                    name: "Поливать растения",
                    color: .appColorSection1,
                    emoji: "❤️",
                    schedule: [.friday, .saturday, .sunday]
                )
            ]
        )
    ]
    /// Список выполненных трекеров
    private var completedTrackers: Set<TrackerRecord> = [
        TrackerRecord(
            trackerId: UUID(
                uuidString: "c35b5998-ee09-497d-a17e-0da346a199b6") ?? UUID(),
            recordDate: Date().removeTimeStamp - 1
        )
    ]

    // MARK: - Initializers

    // MARK: - Public Methods

    func recordTracker(for indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard
            let category = categories[safe: indexPath.section],
            let tracker = category.trackers[safe: indexPath.row]
        else {
            assertionFailure("Критическая ошибка доступа к данным трекеров - искомые категория и/или трекер не найдены")
            completion(.failure(TrackersViewPresenterErrors.trackerNotFound))
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
            let category = categories[safe: indexPath.section],
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

    func trackersCount() -> Int {
        guard let dayOfTheWeek = Weekday.dayOfTheWeek(of: currentDate) else {
            assertionFailure("Ошибка определения дня недели на основании текущей даты")
            return 0
        }
        return categories.reduce(into: 0) {
            $0 += $1.trackers.reduce(into: 0) {
                if $1.schedule.contains(dayOfTheWeek) {
                    $0 += 1
                }
            }
        }
    }

    // MARK: - Private Methods

    /// Используется для определения количества секций (категорий) коллекции трекеров на текущую дату
    /// - Returns: Количество секций трекеров на текущую дату
    private func categoriesCount() -> Int {
        guard let dayOfTheWeek = Weekday.dayOfTheWeek(of: currentDate) else {
            assertionFailure("Ошибка определения дня недели на основании текущей даты")
            return 0
        }
        return categories.reduce(into: 0) {
            if !$1.trackers.filter({
                $0.schedule.contains(dayOfTheWeek)
            }).isEmpty {
                $0 += 1
            }
        }
    }

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
        if trackersCount() == 0 {
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
        return categoriesCount()
    }

    /// Возвращает количество ячеек (трекеров) в заданной секции (категории трекеров) на текущую дату
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - section: Индекс секции в коллекции
    /// - Returns: Количество ячеек (трекеров) в заданной секции (категории трекеров)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let trackersCount = categories[safe: section]?.trackers.count else { return 0 }
        return trackersCount
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
    ///   - collectionViewLayout: Объект размещения для коллекции
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
    ///   - collectionViewLayout: Объект размещения для коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размеры отступов ячеек секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: trackersCellParams.topInset, left: trackersCellParams.leftInset, bottom: trackersCellParams.bottomInset, right: trackersCellParams.rightInset)
    }

    /// Задаёт размеры отступов между строками ячеек заданной секции (категории трекеров)
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект размещения для коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размер отступа между строками ячеек заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return trackersCellParams.lineSpacing
    }

    /// Задаёт размер отступов между ячейками одной строки заданной секции (категории трекеров)
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект размещения для коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размер отступа между ячейками одной строки заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return trackersCellParams.cellSpacing
    }
}
