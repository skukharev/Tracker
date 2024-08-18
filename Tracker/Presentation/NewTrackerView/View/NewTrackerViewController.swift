//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

final class NewTrackerViewController: UIViewController, NewTrackerViewPresenterDelegate {
    // MARK: - Public Properties

    var presenter: NewTrackerViewPresenterProtocol?

    private(set) var trackerType: TrackerType?

    // MARK: - Private Properties

    /// Заголовок окна
    private lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypMedium16
        view.textColor = .appBlack
        view.text = ""
        return view
    }()
    /// Панель с основными элементами управления
    private lazy var controlsScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = true
        return view
    }()
    /// Контейнер для наименования трекера
    private lazy var trackerNameContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fill
        return view
    }()
    /// Поле ввода "Наименование трекера"
    private lazy var trackerName: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .appBlack
        view.backgroundColor = .appBackground
        view.placeholder = "Введите название трекера"
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .leading
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.leftViewMode = .always
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
        view.clearButtonMode = .whileEditing
        view.addTarget(self, action: #selector(trackerNameEditingDidChange), for: .editingChanged)
        return view
    }()
    /// Предупреждение о превышении допустимой длины наименования трекера
    private lazy var trackerNameWarningLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .appRed
        view.font = GlobalConstants.ypRegular17
        view.text = "Ограничение 38 символов"
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()
    /// Кнопки "Категория" и "Расписание"
    private lazy var trackerButtonsTableView: UITableView = {
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
    /// Контейнер для удобного размещения кнопок в соответствии с дизайном
    private lazy var buttonsContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fillProportionally
        return view
    }()
    /// Кнопка "Отменить"
    private lazy var cancelButton: UIButton = {
        let view = UIButton(type: .system)
        let buttonColor: UIColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(buttonColor, for: .normal)
        view.setTitle("Отменить", for: .normal)
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = buttonColor.cgColor
        view.addTarget(self, action: #selector(cancelButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    /// Кнопка "Создать"
    private lazy var createButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Создать", for: .normal)
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(createButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHideKeyboardOnTap()
        trackerButtonsTableView.register(TrackerButtonsCell.classForCoder(), forCellReuseIdentifier: TrackerButtonsCell.Constants.identifier)
        trackerButtonsTableView.dataSource = self
        trackerButtonsTableView.delegate = self
        createAndLayoutViews()
    }

    // MARK: - Public Methods

    func showTrackersNameViolation() {
        trackerNameWarningLabel.isHidden = false
    }

    func hideTrackersNameViolation() {
        trackerNameWarningLabel.isHidden = true
    }

    func setCreateButtonEnable() {
        createButton.backgroundColor = .appEnabledCreateButtonBackground
        createButton.setTitleColor(.appEnabledCreateButtonText, for: .normal)
    }

    func setCreateButtonDisable() {
        createButton.backgroundColor = .appGray
        createButton.setTitleColor(.white, for: .normal)
    }

    /// Конфигурирует представление в зависимости от типа добавляемого трекера
    /// - Parameter trackerType: Тип трекера
    func setupViewsWithTrackerType(trackerType: TrackerType) {
        self.trackerType = trackerType

        switch trackerType {
        case .habit:
            viewTitle.text = "Новая привычка"
            trackerButtonsTableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        case .event:
            viewTitle.text = "Новое нерегулярное событие"
            trackerButtonsTableView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        }
    }

    func updateButtonsPanel() {
        let categoryButtonPath = IndexPath(row: 0, section: 0)
        var buttonsPath = [categoryButtonPath]
        if trackerType == .habit {
            let scheduleButtonPath = IndexPath(row: 1, section: 0)
            buttonsPath.append(scheduleButtonPath)
        }
        trackerButtonsTableView.reloadRows(at: buttonsPath, with: .fade)
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        trackerNameContainer.addArrangedSubview(trackerName)
        trackerNameContainer.addArrangedSubview(trackerNameWarningLabel)
        controlsScrollView.addSubviews([trackerNameContainer, trackerButtonsTableView])
        buttonsContainer.addArrangedSubview(cancelButton)
        buttonsContainer.addArrangedSubview(createButton)
        view.addSubviews([viewTitle, controlsScrollView, buttonsContainer])
        setupConstraints()
        setCreateButtonDisable()
    }

    /// Обработчик нажатия кнопки "Отменить"
    /// - Parameter sender: объект, инициирующий событие
    @objc private func cancelButtonTouchUpInside(_ sender: UIButton) {
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
        dismiss(animated: true)
    }

    /// Обработчик нажатия кнопки "Создать"
    /// - Parameter sender: объект, инициирующий событие
    @objc private func createButtonTouchUpInside(_ sender: UIButton) {
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
        presenter?.saveTracker { [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true)
            case .failure:
                break
            }
        }
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
            /// Заголовок окна
            viewTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            viewTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            /// Панель управления
            controlsScrollView.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: 38),
            controlsScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            controlsScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            controlsScrollView.bottomAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            controlsScrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            /// Панель для наименования трекера
            trackerNameContainer.topAnchor.constraint(equalTo: controlsScrollView.topAnchor),
            trackerNameContainer.leadingAnchor.constraint(equalTo: controlsScrollView.leadingAnchor, constant: 16),
            trackerNameContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            /// Поле ввода "Наименование трекера"
            trackerName.topAnchor.constraint(equalTo: trackerNameContainer.topAnchor),
            trackerName.leadingAnchor.constraint(equalTo: trackerNameContainer.leadingAnchor),
            trackerName.trailingAnchor.constraint(equalTo: trackerNameContainer.trailingAnchor),
            trackerName.heightAnchor.constraint(equalToConstant: 75),
            /// Предупреждение о превышении допустимой длины наименования трекера
            trackerNameWarningLabel.leadingAnchor.constraint(equalTo: trackerNameContainer.leadingAnchor),
            trackerNameWarningLabel.trailingAnchor.constraint(equalTo: trackerNameContainer.trailingAnchor),
            /// Кнопки "Категория" и "Расписание"
            trackerButtonsTableView.topAnchor.constraint(equalTo: trackerNameContainer.bottomAnchor, constant: 24),
            trackerButtonsTableView.leadingAnchor.constraint(equalTo: controlsScrollView.leadingAnchor, constant: 16),
            trackerButtonsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            /// Контейнер для кнопок
            buttonsContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonsContainer.heightAnchor.constraint(equalToConstant: 60),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
        controlsScrollView.contentSize.width = view.bounds.width
    }

    /// Обработчик изменения значения текстового поля ввода "Наименование трекера"
    /// - Parameter sender: объект, инициировавший событие
    @objc private func trackerNameEditingDidChange(_ sender: UITextField) {
        presenter?.processTrackersName(sender.text)
    }
}

// MARK: - UITableViewDataSource

extension NewTrackerViewController: UITableViewDataSource {
    /// Возвращает количество кнопок на панели кнопок экрана редактирования трекера
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - section: индекс секции, для которой запрашивается количество кнопок
    /// - Returns: Количество кнопок на панели
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch trackerType {
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
            print("Нажата кнопка Категория")
        } else {
            presenter?.showTrackerSchedule()
        }
    }
}
