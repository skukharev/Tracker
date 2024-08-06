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

    // MARK: - Constants

    // MARK: - Public Properties

    // MARK: - IBOutlet

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
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    /// Заголовок "Трекеры"
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.ypBold34
        label.textColor = .appBlack
        label.text = "Трекеры"
        return label
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
        label.font = Constants.ypMedium12
        label.textColor = .appBlack
        label.text = "Что будем отслеживать?"
        return label
    }()

    // MARK: - Initializers

    // MARK: - Public Methods

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createAndLayoutViews()
        presenter?.loadTrackers()
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
        } else {
            trackersStubImage.isHidden = false
        }
    }
    // MARK: - IBAction

    // MARK: - Private Methods
    /// Обработчик нажатия кнопки "Добавить трекер"
    @objc private func addTrackerTouchUpInside(_ sender: UIButton) {
        print("Add tracker button pressed")
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trackersChooseDatePicker)
        view.addSubviews([trackersLabel])
        setupConstraints()
    }

    // Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        guard let targetView = navigationController?.navigationBar else { return }
        NSLayoutConstraint.activate(
            [
                trackersLabel.topAnchor.constraint(equalTo: targetView.bottomAnchor, constant: 1),
                trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                trackersLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -105)
            ]
        )
    }
}
