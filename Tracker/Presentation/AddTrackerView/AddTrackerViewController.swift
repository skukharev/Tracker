//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.08.2024.
//

import UIKit

final class AddTrackerViewController: UIViewController, AddTrackerViewPresenterDelegate {
    // MARK: - Public Properties

    var presenter: AddTrackerViewPresenterProtocol?

    // MARK: - Private Properties

    /// Заголовок окна
    private lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypMedium16
        view.textColor = .appBlack
        view.text = "Создание трекера"
        return view
    }()
    /// Контейнер для удобного размещения кнопок в соответствии с дизайном
    private lazy var buttonsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    /// Кнопка "Добавить привычку"
    private lazy var addHabitButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(.appWhite, for: .normal)
        view.setTitle("Привычка", for: .normal)
        view.backgroundColor = .appBlack
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(addHabitButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    /// Кнопка "Добавить нерегулярное событие"
    private lazy var addEventButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(.appWhite, for: .normal)
        view.setTitle("Нерегулярное событие", for: .normal)
        view.backgroundColor = .appBlack
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(addEventButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
    }

    // MARK: - Public Methods

    /// Используется для связи вью контроллера с презентером
    /// - Parameter presenter: презентер вью контроллера
    func configure(_ presenter: AddTrackerViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    func hide() {
        dismiss(animated: true)
    }

    // MARK: - Private Methods

    /// Обработчик нажатия на кнопку "Добавить привычку"
    /// - Parameter sender: объект-иницатор события
    @objc private func addHabitButtonTouchUpInside(_ sender: UIButton) {
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
        presenter?.addHabit()
    }

    /// Обработчик нажатия на кнопку "Добавить нерегулярное событие"
    /// - Parameter sender: объект-инициатор события
    @objc private func addEventButtonTouchUpInside(_ sender: UIButton) {
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
        presenter?.addEvent()
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        buttonsContainer.addSubviews([addHabitButton, addEventButton])
        view.addSubviews([viewTitle, buttonsContainer])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            /// Заголовок окна
            viewTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            viewTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            /// Контейнер для кнопок
            buttonsContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonsContainer.heightAnchor.constraint(equalToConstant: 136),
            buttonsContainer.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            /// Кнопка "Привычка"
            addHabitButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            addHabitButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            addHabitButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60),
            /// Кнопка "Нерегулярное событие"
            addEventButton.topAnchor.constraint(equalTo: addHabitButton.bottomAnchor, constant: 16),
            addEventButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            addEventButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            addEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
