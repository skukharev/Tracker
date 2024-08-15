//
//  TrackerScheduleViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 15.08.2024.
//

import UIKit

final class ScheduleViewController: UIViewController, ScheduleViewPresenterDelegate {
    // MARK: - Public Properties

    var presenter: ScheduleViewPresenterProtocol?

    // MARK: - Private Properties

    /// Заголовок окна
    private lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypMedium16
        view.textColor = .appBlack
        view.text = "Расписание"
        return view
    }()
    /// Расписание трекера
    private lazy var scheduleTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorEffect = .none
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.allowsSelection = true
        view.alwaysBounceVertical = true
        view.insetsContentViewsToSafeArea = true
        view.contentInsetAdjustmentBehavior = .automatic
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.rowHeight = 75
        view.estimatedRowHeight = view.rowHeight
        return view
    }()
    /// Кнопка "Готово"
    private lazy var readyButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(.appWhite, for: .normal)
        view.setTitle("Готово", for: .normal)
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.backgroundColor = .appBlack
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(readyButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.needSaveSchedule()
    }

    // MARK: - Public Methods

    /// Используется для связи вью контроллера с презентером
    /// - Parameter presenter: презентер вью контроллера
    func configure(_ presenter: ScheduleViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
        scheduleTableView.register(ScheduleCell.classForCoder(), forCellReuseIdentifier: ScheduleCell.Constants.identifier)
        scheduleTableView.dataSource = presenter
        scheduleTableView.delegate = presenter
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        view.addSubviews([viewTitle, scheduleTableView, readyButton])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                /// Заголовок окна
                viewTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
                viewTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                /// Расписание трекера
                scheduleTableView.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: 30),
                scheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                scheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                scheduleTableView.heightAnchor.constraint(equalToConstant: 75 * 7),
                /// Кнопка "Готово"
                readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                readyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                readyButton.heightAnchor.constraint(equalToConstant: 60),
                readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            ]
        )
    }

    /// Обработчик нажатия кнопки "Готово"
    /// - Parameter sender: объект, инициирующий событие
    @objc private func readyButtonTouchUpInside(_ sender: UIButton) {
        UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view).impactOccurred()
        dismiss(animated: true)
    }
}
