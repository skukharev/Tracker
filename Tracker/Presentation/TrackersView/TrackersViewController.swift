//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation
import UIKit

final class TrackersViewController: UIViewController, TrackersViewPresenterDelegate {
    // MARK: - Types

    private enum Identifiers {
        static let addTrackerButtonImageName = "AddTrackerImage"
        static let trackersStubImageName = "TrackersStub"
    }

    // MARK: - Private Properties

    private var presenter: TrackersViewPresenterProtocol?
    /// Кнопка "Добавить трекер"
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: Identifiers.addTrackerButtonImageName), for: .normal)
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
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
        return datePicker
    }()
    /// Заглушка списка с трекерами
    private lazy var trackersStubImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        guard let stubImage = UIImage(named: Identifiers.trackersStubImageName) else {
            assertionFailure("Ошибка загрузки логотипа заглушки")
            return image
        }
        image.image = stubImage
        image.contentMode = .center
        return image
    }()
    /// Текст заглушки списка с трекерами
    private lazy var trackersStubImageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = GlobalConstants.ypMedium12
        label.textColor = .appBlack
        label.text = "Что будем отслеживать?"
        return label
    }()
    /// Панель поиска  трекеров
    private lazy var trackersSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Поиск"
        searchBar.searchTextField.font = GlobalConstants.ypRegular17
        return searchBar
    }()
    /// Коллекция трекеров
    private lazy var trackersCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .appWhite
        return collectionView
    }()

    // MARK: - Public Methods

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupHideKeyboardOnTap()
        createAndLayoutViews()
        presenter?.currentDate = Date()
    }

    /// Используется для связи вью контроллера с презентером
    /// - Parameter presenter: презентер вью контроллера
    func configure(_ presenter: TrackersViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    func showTrackersListStub() {
        if !view.subviews.contains(trackersStubImage) {
            view.addSubviews([trackersStubImage, trackersStubImageLabel])
            NSLayoutConstraint.activate(
                [
                    // Заглушка
                    trackersStubImage.widthAnchor.constraint(equalToConstant: 80),
                    trackersStubImage.heightAnchor.constraint(equalToConstant: 80),
                    trackersStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                    trackersStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                    // Текст заглушки
                    trackersStubImageLabel.topAnchor.constraint(equalTo: trackersStubImage.bottomAnchor, constant: 8),
                    trackersStubImageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
                ]
            )
        }
        trackersCollection.isHidden = true
        trackersStubImage.isHidden = false
        trackersStubImageLabel.isHidden = false
    }

    func showTrackersList() {
        if view.subviews.contains(trackersStubImage) {
            trackersStubImage.isHidden = true
        }
        if view.subviews.contains(trackersStubImageLabel) {
            trackersStubImageLabel.isHidden = true
        }
        trackersCollection.isHidden = false
        trackersCollection.reloadData()
    }

    // MARK: - Private Methods

    /// Обработчик нажатия кнопки "Добавить трекер"
    /// - Parameter sender: объект-инициатор события
    @objc private func addTrackerTouchUpInside(_ sender: UIButton) {
        presenter?.addTracker { [weak self] addTrackerViewController in
            guard let viewController = addTrackerViewController as? UIViewController else { return }
            self?.present(viewController, animated: true)
        }
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
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trackersChooseDatePicker)
        /// Элементы управления
        view.addSubviews([trackersSearchBar, trackersCollection])
        trackersCollection.register(TrackersCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersCollectionHeaderView.Constants.identifier)
        trackersCollection.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.Constants.identifier)
        trackersCollection.dataSource = presenter
        trackersCollection.delegate = presenter
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
        guard
            let navBar = navigationController?.navigationBar,
            let tabBar = navigationController?.tabBarController?.tabBar
        else { return }

        NSLayoutConstraint.activate(
            [
                /// Кнопка поиска трекеров
                trackersSearchBar.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 7),
                trackersSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                trackersSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                /// Коллекция трекеров
                trackersCollection.topAnchor.constraint(equalTo: trackersSearchBar.bottomAnchor, constant: 10),
                trackersCollection.leadingAnchor.constraint(equalTo: trackersSearchBar.leadingAnchor),
                trackersCollection.trailingAnchor.constraint(equalTo: trackersSearchBar.trailingAnchor),
                trackersCollection.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
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
        }
        if sender.direction == .right {
            let newDate = Calendar.current.date(byAdding: .day, value: -1, to: trackersChooseDatePicker.date) ?? trackersChooseDatePicker.date
            trackersChooseDatePicker.setDate(newDate, animated: true)
            datePickerValueChanged(trackersChooseDatePicker)
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
