//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

final class NewTrackerViewController: UIViewController, NewTrackerViewPresenterDelegate { // swiftlint:disable:this type_body_length
    // MARK: - Types

    enum Constants {
        static let trackerNameContainerSpacing: CGFloat = 8
        static let trackerNameContainerLeadingConstraint: CGFloat = 16
        static let trackerNamePlaceholderTitle = "Введите название трекера"
        static let trackerNameCornerRadius: CGFloat = 16
        static let trackerNameLeftViewFrame = CGRect(x: 0, y: 0, width: 16, height: 10)
        static let trackerNameWarningLabelText = "Ограничение 38 символов"
        static let trackerNameHeightConstraint: CGFloat = 75
        static let trackerButtonsTableViewSeparatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let trackerButtonsTableViewCornerRadius: CGFloat = 16
        static let trackerButtonsTableViewRowHeight: CGFloat = 75
        static let trackerButtonsTableViewTopConstraint: CGFloat = 24
        static let trackerButtonsTableViewLeadingConstraint: CGFloat = 16
        static let trackerButtonsTableViewHeightForHabit: CGFloat = 150
        static let trackerButtonsTableViewHeightForEvent: CGFloat = 75
        static let emojiLabelText = "Emoji"
        static let emojiLabelTopConstraint: CGFloat = 32
        static let emojiLabelLeadingConstraint: CGFloat = 28
        static let colorsLabelText = "Цвет"
        static let colorsLabelTopConstraint: CGFloat = 16
        static let colorsLabelLeadingConstraint: CGFloat = 28
        static let buttonsContainerSpacing: CGFloat = 8
        static let buttonsContainerLeadingConstraint: CGFloat = 20
        static let buttonsContainerHeightConstraint: CGFloat = 60
        static let cancelButtonTitle = "Отменить"
        static let cancelButtonCornerRadius: CGFloat = 16
        static let cancelButtonBorderWidth: CGFloat = 1
        static let createButtonTitle = "Создать"
        static let createButtonCornerRadius: CGFloat = 16
        static let viewTitleForHabitText = "Новая привычка"
        static let viewTitleForEventText = "Новое нерегулярное событие"
        static let viewTitleTopConstraint: CGFloat = 27
        static let controlsScrollViewTopConstraint: CGFloat = 38
    }

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
        view.spacing = Constants.trackerNameContainerSpacing
        view.distribution = .fill
        return view
    }()
    /// Поле ввода "Наименование трекера"
    private lazy var trackerName: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .appBlack
        view.backgroundColor = .appBackground
        view.placeholder = Constants.trackerNamePlaceholderTitle
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .leading
        view.layer.cornerRadius = Constants.trackerNameCornerRadius
        view.layer.masksToBounds = true
        view.leftViewMode = .always
        view.leftView = UIView(frame: Constants.trackerNameLeftViewFrame)
        view.clearButtonMode = .whileEditing
        view.returnKeyType = .done
        view.delegate = self
        view.addTarget(self, action: #selector(trackerNameEditingDidChange), for: .editingChanged)
        return view
    }()
    /// Предупреждение о превышении допустимой длины наименования трекера
    private lazy var trackerNameWarningLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .appRed
        view.font = GlobalConstants.ypRegular17
        view.text = Constants.trackerNameWarningLabelText
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()
    /// Кнопки "Категория" и "Расписание"
    private lazy var trackerButtonsTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorInset = Constants.trackerButtonsTableViewSeparatorInset
        view.allowsSelection = true
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = Constants.trackerButtonsTableViewCornerRadius
        view.layer.masksToBounds = true
        view.rowHeight = Constants.trackerButtonsTableViewRowHeight
        view.estimatedRowHeight = view.rowHeight
        return view
    }()
    /// Заголовок коллекции Emoji
    private lazy var emojiLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypBold19
        view.textColor = .appBlack
        view.text = Constants.emojiLabelText
        return view
    }()
    /// Коллекция Emoji
    internal lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.allowsMultipleSelection = false
        view.allowsSelection = true
        return view
    }()
    /// Заголовок коллекции с цветами трекера
    private lazy var colorsLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypBold19
        view.textColor = .appBlack
        view.text = Constants.colorsLabelText
        return view
    }()
    /// Коллекция с цветами трекера
    internal lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.allowsMultipleSelection = false
        view.allowsSelection = true
        return view
    }()
    /// Контейнер для удобного размещения кнопок в соответствии с дизайном
    private lazy var buttonsContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = Constants.buttonsContainerSpacing
        view.distribution = .fillProportionally
        return view
    }()
    /// Кнопка "Отменить"
    private lazy var cancelButton: UIButton = {
        let view = UIButton(type: .system)
        let buttonColor: UIColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(buttonColor, for: .normal)
        view.setTitle(Constants.cancelButtonTitle, for: .normal)
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = Constants.cancelButtonCornerRadius
        view.layer.masksToBounds = true
        view.layer.borderWidth = Constants.cancelButtonBorderWidth
        view.layer.borderColor = buttonColor.cgColor
        view.addTarget(self, action: #selector(cancelButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    /// Кнопка "Создать"
    private lazy var createButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle(Constants.createButtonTitle, for: .normal)
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = Constants.createButtonCornerRadius
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(createButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    /// Параметры отображения элементов управления в зависимости от типа устройства, на котором запущено приложение
    internal var geometricParams: NewTrackerViewControllerGeometricParams {
        if UIDevice.current.isiPhoneSE {
            return NewTrackerViewControllerGeometricParams(
                collectionViewHeight: 192,
                collectionViewParams: UICollectionViewCellGeometricParams(cellCount: 6, topInset: 24, leftInset: 16, rightInset: 16, bottomInset: 24, cellSpacing: 0, lineSpacing: 0, cellHeight: 48, cellWidth: 48)
            )
        } else {
            return NewTrackerViewControllerGeometricParams(
                collectionViewHeight: 204,
                collectionViewParams: UICollectionViewCellGeometricParams(cellCount: 6, topInset: 24, leftInset: 18, rightInset: 18, bottomInset: 24, cellSpacing: 5, lineSpacing: 0, cellHeight: 52, cellWidth: 52)
            )
        }
    }

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHideKeyboardOnTap()
        /// Инициализация табличного представления с кнопками
        trackerButtonsTableView.register(TrackerButtonsCell.classForCoder(), forCellReuseIdentifier: TrackerButtonsCell.Constants.identifier)
        trackerButtonsTableView.dataSource = self
        trackerButtonsTableView.delegate = self
        /// Инициализация коллекции с эмоджи
        emojiCollectionView.register(NewTrackerEmojiCell.classForCoder(), forCellWithReuseIdentifier: NewTrackerEmojiCell.Constants.identifier)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        /// Инициализация коллекции с цветами трекера
        colorsCollectionView.register(NewTrackerColorCell.classForCoder(), forCellWithReuseIdentifier: NewTrackerColorCell.Constants.identifier)
        colorsCollectionView.dataSource = self
        colorsCollectionView.delegate = self
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
            viewTitle.text = Constants.viewTitleForHabitText
            trackerButtonsTableView.heightAnchor.constraint(equalToConstant: Constants.trackerButtonsTableViewHeightForHabit).isActive = true
        case .event:
            viewTitle.text = Constants.viewTitleForEventText
            trackerButtonsTableView.heightAnchor.constraint(equalToConstant: Constants.trackerButtonsTableViewHeightForEvent).isActive = true
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
        buttonsContainer.addArrangedSubview(cancelButton)
        buttonsContainer.addArrangedSubview(createButton)
        controlsScrollView.addSubviews([trackerNameContainer, trackerButtonsTableView, emojiLabel, emojiCollectionView, colorsLabel, colorsCollectionView, buttonsContainer])
        view.addSubviews([viewTitle, controlsScrollView])
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
            viewTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.viewTitleTopConstraint),
            viewTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            /// Панель управления
            controlsScrollView.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: Constants.controlsScrollViewTopConstraint),
            controlsScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            controlsScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            controlsScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controlsScrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            /// Панель для наименования трекера
            trackerNameContainer.topAnchor.constraint(equalTo: controlsScrollView.topAnchor),
            trackerNameContainer.leadingAnchor.constraint(equalTo: controlsScrollView.leadingAnchor, constant: Constants.trackerNameContainerLeadingConstraint),
            trackerNameContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.trackerNameContainerLeadingConstraint),
            /// Поле ввода "Наименование трекера"
            trackerName.topAnchor.constraint(equalTo: trackerNameContainer.topAnchor),
            trackerName.leadingAnchor.constraint(equalTo: trackerNameContainer.leadingAnchor),
            trackerName.trailingAnchor.constraint(equalTo: trackerNameContainer.trailingAnchor),
            trackerName.heightAnchor.constraint(equalToConstant: Constants.trackerNameHeightConstraint),
            /// Предупреждение о превышении допустимой длины наименования трекера
            trackerNameWarningLabel.leadingAnchor.constraint(equalTo: trackerNameContainer.leadingAnchor),
            trackerNameWarningLabel.trailingAnchor.constraint(equalTo: trackerNameContainer.trailingAnchor),
            /// Кнопки "Категория" и "Расписание"
            trackerButtonsTableView.topAnchor.constraint(equalTo: trackerNameContainer.bottomAnchor, constant: Constants.trackerButtonsTableViewTopConstraint),
            trackerButtonsTableView.leadingAnchor.constraint(equalTo: controlsScrollView.leadingAnchor, constant: Constants.trackerButtonsTableViewLeadingConstraint),
            trackerButtonsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.trackerButtonsTableViewLeadingConstraint),
            /// Заголовок коллекции Emoji
            emojiLabel.topAnchor.constraint(equalTo: trackerButtonsTableView.bottomAnchor, constant: Constants.emojiLabelTopConstraint),
            emojiLabel.leadingAnchor.constraint(equalTo: controlsScrollView.leadingAnchor, constant: Constants.emojiLabelLeadingConstraint),
            /// Коллекция Emoji
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: controlsScrollView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: geometricParams.collectionViewHeight),
            /// Заголовок коллекции с цветами
            colorsLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: Constants.colorsLabelTopConstraint),
            colorsLabel.leadingAnchor.constraint(equalTo: controlsScrollView.leadingAnchor, constant: Constants.colorsLabelLeadingConstraint),
            /// Коллекция с цветами трекера
            colorsCollectionView.topAnchor.constraint(equalTo: colorsLabel.bottomAnchor),
            colorsCollectionView.leadingAnchor.constraint(equalTo: controlsScrollView.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: geometricParams.collectionViewHeight),
            /// Контейнер для кнопок
            buttonsContainer.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor),
            buttonsContainer.leadingAnchor.constraint(equalTo: controlsScrollView.leadingAnchor, constant: Constants.buttonsContainerLeadingConstraint),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.buttonsContainerLeadingConstraint),
            buttonsContainer.heightAnchor.constraint(equalToConstant: Constants.buttonsContainerHeightConstraint),
            /// Без этого констрейнта ниже отображение элементов скролл-вью будет некорректным
            buttonsContainer.bottomAnchor.constraint(equalTo: controlsScrollView.bottomAnchor)
            ]
        )
    }

    /// Обработчик изменения значения текстового поля ввода "Наименование трекера"
    /// - Parameter sender: объект, инициировавший событие
    @objc private func trackerNameEditingDidChange(_ sender: UITextField) {
        presenter?.processTrackersName(sender.text)
    }
}
