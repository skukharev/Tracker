//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import UIKit

final class TrackersViewController: UIViewController, TrackersViewPresenterDelegate {
    // MARK: - Types

    internal enum Constants {
        static let trackersCellParams = UICollectionViewCellGeometricParams(cellCount: 2, topInset: 0, leftInset: 0, rightInset: 0, bottomInset: 0, cellSpacing: 9, lineSpacing: 10, cellHeight: 148)
        static let trackersChooseDatePickerCornerRadius: CGFloat = 8
        static let trackersStubImageLabelText = L10n.trackersStubImageLabelText
        static let trackersSearchBarPlaceholder = L10n.trackersSearchBarPlaceholder
        static let trackersSearchBarLeadingConstraint: CGFloat = 16
        static let trackersStubImageWidthConstraint: CGFloat = 80
        static let trackersStubImageLabelTopConstraint: CGFloat = 8
        static let trackersCollectionTopConstraint: CGFloat = 10
        static let confirmTrackerDeleteAlertMessage = L10n.confirmTrackerDeleteAlertMessage
        static let confirmTrackerDeleteAlertNoButtonText = L10n.confirmTrackerDeleteAlertNoButtonText
        static let confirmTrackerDeleteAlertYesButtonText = L10n.confirmTrackerDeleteAlertYesButtonText
    }

    // MARK: - Private Properties

    private var presenter: TrackersViewPresenterProtocol?
    /// Кнопка "Добавить трекер"
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Asset.Images.addTrackerImage.image, for: .normal)
        button.tintColor = .appBlack
        button.addTarget(self, action: #selector(addTrackerTouchUpInside(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = "AddTracker"
        return button
    }()
    /// Элемент управления" "Дата трекера"
    private lazy var trackersChooseDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        let currentDate = Date()
        datePicker.locale = Locale.autoupdatingCurrent
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.backgroundColor = .appDatePickerBackground
        datePicker.setValue(UIColor.appDatePickerText, forKey: "textColor")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.layer.cornerRadius = Constants.trackersChooseDatePickerCornerRadius
        datePicker.layer.masksToBounds = true
        return datePicker
    }()
    /// Заглушка списка с трекерами
    private lazy var trackersStubImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = Asset.Images.trackersStub.image
        image.contentMode = .center
        return image
    }()
    /// Текст заглушки списка с трекерами
    private lazy var trackersStubImageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = GlobalConstants.ypMedium12
        label.textColor = .appBlack
        label.text = Constants.trackersStubImageLabelText
        return label
    }()
    /// Панель поиска  трекеров
    private lazy var trackersSearchBar: UISearchBar = {
        let view = UISearchBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.searchBarStyle = .minimal
        view.placeholder = Constants.trackersSearchBarPlaceholder
        return view
    }()
    /// Коллекция трекеров
    internal lazy var trackersCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .appWhite
        return collectionView
    }()

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
        self.setupHideKeyboardOnTap()
        presenter?.currentDate = Date()
    }

    func configure(_ presenter: TrackersViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    func hideTrackersListStub() {
        if view.subviews.contains(trackersStubImage) {
            trackersStubImage.isHidden = true
        }
        if view.subviews.contains(trackersStubImageLabel) {
            trackersStubImageLabel.isHidden = true
        }
    }

    func showTrackersListStub() {
        if !view.subviews.contains(trackersStubImage) {
            view.addSubviews([trackersStubImage, trackersStubImageLabel])
            NSLayoutConstraint.activate(
                [
                    // Заглушка
                    trackersStubImage.widthAnchor.constraint(equalToConstant: Constants.trackersStubImageWidthConstraint),
                    trackersStubImage.heightAnchor.constraint(equalToConstant: Constants.trackersStubImageWidthConstraint),
                    trackersStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                    trackersStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                    // Текст заглушки
                    trackersStubImageLabel.topAnchor.constraint(equalTo: trackersStubImage.bottomAnchor, constant: Constants.trackersStubImageLabelTopConstraint),
                    trackersStubImageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
                ]
            )
        }
        trackersStubImage.isHidden = false
        trackersStubImageLabel.isHidden = false
        trackersCollection.isHidden = true
    }

    func showTrackersList() {
        hideTrackersListStub()
        trackersCollection.reloadData()
        trackersCollection.isHidden = false
    }

    func updateTrackersCollection(at indexPaths: TrackerStoreUpdate) {
        trackersCollection.performBatchUpdates {
            if let deletedSectionIndexes = indexPaths.deletedSectionIndexes, !deletedSectionIndexes.isEmpty {
                trackersCollection.deleteSections(deletedSectionIndexes)
            }
            if !indexPaths.deletedPaths.isEmpty {
                trackersCollection.deleteItems(at: indexPaths.deletedPaths)
            }
            if let insertedSectionIndexes = indexPaths.insertedSectionIndexes, !insertedSectionIndexes.isEmpty {
                trackersCollection.insertSections(insertedSectionIndexes)
            }
            if !indexPaths.movedPaths.isEmpty {
                indexPaths.movedPaths.forEach {
                    trackersCollection.deleteItems(at: [$0.0])
                    trackersCollection.insertItems(at: [$0.1])
                }
            }
            if !indexPaths.insertedPaths.isEmpty {
                trackersCollection.insertItems(at: indexPaths.insertedPaths)
            }
            if !indexPaths.updatedPaths.isEmpty {
                trackersCollection.reloadItems(at: indexPaths.updatedPaths)
            }
        }
    }

    // MARK: - Private Methods

    /// Обработчик нажатия кнопки "Добавить трекер"
    /// - Parameter sender: объект-инициатор события
    @objc private func addTrackerTouchUpInside(_ sender: UIButton) {
        presenter?.addTracker()
    }

    internal func confirmTrackerDelete(at indexPath: IndexPath) {
        let alertView = UIAlertController(
            title: nil,
            message: Constants.confirmTrackerDeleteAlertMessage,
            preferredStyle: .actionSheet
        )
        alertView.addAction(UIAlertAction(title: Constants.confirmTrackerDeleteAlertNoButtonText, style: .cancel))
        alertView.addAction(
            UIAlertAction(
                title: Constants.confirmTrackerDeleteAlertYesButtonText,
                style: .destructive) { [weak self] _ in
                    self?.presenter?.deleteTracker(at: indexPath) { _ in }
            }
        )
        present(alertView, animated: true)
    }

    ///  Обработчик изменения значения элемента управления датами
    /// - Parameter sender: объект-инициатор события
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        presenter?.currentDate = sender.date
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        window?.backgroundColor = .appWhite
        /// Панель навигации
        navigationItem.title = L10n.trackersTabBarItemTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trackersChooseDatePicker)
        /// Элементы управления
        view.addSubviews([trackersSearchBar, trackersCollection])
        trackersSearchBar.delegate = self
        trackersCollection.register(TrackersCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersCollectionHeaderView.Constants.identifier)
        trackersCollection.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.Constants.identifier)
        trackersCollection.dataSource = self
        trackersCollection.delegate = self
        /// Разметка элементов управления
        setupConstraints()
        /// Обработчики свайпом влево и вправо
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                /// Кнопка поиска трекеров
                trackersSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                trackersSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.trackersSearchBarLeadingConstraint),
                trackersSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.trackersSearchBarLeadingConstraint),
                /// Коллекция трекеров
                trackersCollection.topAnchor.constraint(equalTo: trackersSearchBar.bottomAnchor, constant: Constants.trackersCollectionTopConstraint),
                trackersCollection.leadingAnchor.constraint(equalTo: trackersSearchBar.leadingAnchor),
                trackersCollection.trailingAnchor.constraint(equalTo: trackersSearchBar.trailingAnchor),
                trackersCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
    }

    /// Обработчик жестов свайп-влево и свайп-впарво
    /// - Parameter sender: объект-источник события
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            let newDate = Calendar.current.date(byAdding: .day, value: 1, to: trackersChooseDatePicker.date) ?? trackersChooseDatePicker.date
            trackersChooseDatePicker.setDate(newDate, animated: true)
            datePickerValueChanged(trackersChooseDatePicker)
            UIImpactFeedbackGenerator.initiate(style: .soft, view: self.view).impactOccurred()
        }
        if sender.direction == .right {
            let newDate = Calendar.current.date(byAdding: .day, value: -1, to: trackersChooseDatePicker.date) ?? trackersChooseDatePicker.date
            trackersChooseDatePicker.setDate(newDate, animated: true)
            datePickerValueChanged(trackersChooseDatePicker)
            UIImpactFeedbackGenerator.initiate(style: .soft, view: self.view).impactOccurred()
        }
    }
}

// MARK: - TrackersCollectionViewCellDelegate

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func trackersCollectionViewCellDidTapRecord(_ cell: TrackersCollectionViewCell, _ completion: @escaping () -> Void) {
        guard let indexPath = trackersCollection.indexPath(for: cell) else {
            completion()
            return
        }
        presenter?.recordTracker(for: indexPath) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.showCell(for: cell, with: indexPath)
            default: break
            }
        }
        completion()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    /// Возвращает количество секций (категорий теркеров) коллекции трекеров на текущую дату
    /// - Parameter collectionView: Элемент управления
    /// - Returns: Количество секций (категорий трекеров)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let presenter = presenter else {
            assertionFailure("Ошибка инициализации ассоциированного презентера")
            return 0
        }
        return presenter.trackerCategoriesCount()
    }

    /// Возвращает количество ячеек (трекеров) в заданной секции (категории трекеров) на текущую дату
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - section: Индекс секции в коллекции
    /// - Returns: Количество ячеек (трекеров) в заданной секции (категории трекеров)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.trackersCount(inSection: section)
    }

    /// Используется для визуального оформления заголовка секции коллекции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - kind: Тип: заголовок/футер
    ///   - indexPath: Индекс заголовка секции в коллекции
    /// - Returns: Сконфигурированная и готовый к отображению заголовок коллекции трекеров
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: TrackersCollectionHeaderView.Constants.identifier,
                for: indexPath
            ) as? TrackersCollectionHeaderView else {
                assertionFailure("Элемент управления заголовком секции трекеров не найден")
                return UICollectionReusableView()
            }
            presenter?.showHeader(for: view, with: indexPath)
            return view
        default:
            break
        }
        return UICollectionReusableView()
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
        cell.delegate = self
        presenter?.showCell(for: cell, with: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    /// Задаёт размеры отображаемой ячейки в коллекции трекеров
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - indexPath: Индекс ячейки в коллекции трекеров
    /// - Returns: Размер ячейки с трекером
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - Constants.trackersCellParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(Constants.trackersCellParams.cellCount)
        return CGSize(width: cellWidth, height: Constants.trackersCellParams.cellHeight)
    }

    /// Задаёт размеры отступов ячеек заданной секции (категории трекеров) от границ коллекции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размеры отступов ячеек секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: Constants.trackersCellParams.topInset, left: Constants.trackersCellParams.leftInset, bottom: Constants.trackersCellParams.bottomInset, right: Constants.trackersCellParams.rightInset)
    }

    /// Задаёт размеры отступов между строками ячеек заданной секции (категории трекеров)
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размер отступа между строками ячеек заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.trackersCellParams.lineSpacing
    }

    /// Задаёт размер отступов между ячейками одной строки заданной секции (категории трекеров)
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размер отступа между ячейками одной строки заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.trackersCellParams.cellSpacing
    }

    /// Задаёт размер заголовка секции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции (категории трекеров)
    /// - Returns: Размер заголовка секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)

        let headerView = TrackersCollectionHeaderView()
        presenter?.showHeader(for: headerView, with: indexPath)

        let headerSize = headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: 30),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return headerSize
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: L10n.trackersCollectionMenuEditTitle) { [weak self] _ in
                self?.presenter?.editTracker(at: indexPath) { _ in }
            }
            let deleteAction = UIAction(title: L10n.trackersCollectionMenuDeleteTitle, attributes: .destructive) { [weak self] _ in
                self?.confirmTrackerDelete(at: indexPath)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.trackersFilter = searchText
    }
} // swiftlint:disable:this file_length
