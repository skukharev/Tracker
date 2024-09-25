//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

// swiftlint:disable:next type_body_length
final class NewTrackerViewController: UIViewController, NewTrackerViewPresenterDelegate {
    // MARK: - Types

    enum Constants {
        static let viewTitleFont = GlobalConstants.ypMedium16
        static let viewTitleTextColor = UIColor.appBlack
        static let trackerRepeatsTitleFont = GlobalConstants.ypBold32
        static let trackerRepeatsTitleTextColor = UIColor.appBlack
        static let trackerRepeatsTitleHeightConstraint: CGFloat = 38
        static let trackerRepeatsFooterHeightConstraint: CGFloat = 24
        static let trackerNameContainerSpacing: CGFloat = 8
        static let trackerNameContainerLeadingConstraint: CGFloat = 16
        static let trackerNamePlaceholderTitle = L10n.trackerNamePlaceholderTitle
        static let trackerNameCornerRadius: CGFloat = 16
        static let trackerNameLeftViewFrame = CGRect(x: 0, y: 0, width: 16, height: 10)
        static let trackerNameWarningLabelText = L10n.trackerNameWarningLabelText
        static let trackerNameHeightConstraint: CGFloat = 75
        static let trackerButtonsTableViewSeparatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let trackerButtonsTableViewCornerRadius: CGFloat = 16
        static let trackerButtonsTableViewRowHeight: CGFloat = 75
        static let trackerButtonsTableViewTopConstraint: CGFloat = 24
        static let trackerButtonsTableViewLeadingConstraint: CGFloat = 16
        static let trackerButtonsTableViewHeightForHabit: CGFloat = 150
        static let trackerButtonsTableViewHeightForEvent: CGFloat = 75
        static let emojiLabelText = L10n.emojiLabelText
        static let emojiLabelTopConstraint: CGFloat = 32
        static let emojiLabelLeadingConstraint: CGFloat = 28
        static let colorsLabelText = L10n.colorsLabelText
        static let colorsLabelTopConstraint: CGFloat = 16
        static let colorsLabelLeadingConstraint: CGFloat = 28
        static let buttonsContainerSpacing: CGFloat = 8
        static let buttonsContainerLeadingConstraint: CGFloat = 20
        static let buttonsContainerHeightConstraint: CGFloat = 60
        static let cancelButtonTitle = L10n.cancelButtonTitle
        static let cancelButtonCornerRadius: CGFloat = 16
        static let cancelButtonBorderWidth: CGFloat = 1
        static let saveButtonCornerRadius: CGFloat = 16
        static let viewTitleTopConstraint: CGFloat = 27
        static let controlsScrollViewTopConstraint: CGFloat = 38
    }

    // MARK: - Constants

    private let presenter: NewTrackerViewPresenterProtocol

    // MARK: - Private Properties

    /// Заголовок окна
    private lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.viewTitleFont
        view.textColor = Constants.viewTitleTextColor
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
    /// Заголовок с количеством повторений трекера (для привычек)
    private lazy var trackerRepeatsTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.trackerRepeatsTitleFont
        view.textColor = Constants.trackerRepeatsTitleTextColor
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()
    /// Подвал для заголовка с количеством повторений трекера (для привычек)
    private lazy var trackerRepeatsFooter: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
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
    private lazy var emojiCollectionView: UICollectionView = {
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
    private lazy var colorsCollectionView: UICollectionView = {
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
    private lazy var saveButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = Constants.saveButtonCornerRadius
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(saveButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    /// Параметры отображения элементов управления в зависимости от типа устройства, на котором запущено приложение
    private var geometricParams: NewTrackerViewControllerGeometricParams {
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
    private var emojiIndexPath: IndexPath?
    private var colorIndexPath: IndexPath?

    // MARK: - Initializers

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(withPresenter presenter: NewTrackerViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.viewController = self
    }

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let emojiIndexPath = emojiIndexPath {
            emojiCollectionView.performBatchUpdates(nil) { _ in
                self.emojiCollectionView.selectItem(at: emojiIndexPath, animated: false, scrollPosition: .centeredVertically)
                self.emojiCollectionView.delegate?.collectionView?(self.emojiCollectionView, didSelectItemAt: emojiIndexPath)
            }
        }
        if let colorIndexPath = colorIndexPath {
            colorsCollectionView.performBatchUpdates(nil) { _ in
                self.colorsCollectionView.selectItem(at: colorIndexPath, animated: false, scrollPosition: .centeredVertically)
                self.colorsCollectionView.delegate?.collectionView?(self.colorsCollectionView, didSelectItemAt: colorIndexPath)
            }
        }
    }

    // MARK: - Public Methods

    func showTrackersNameViolation() {
        trackerNameWarningLabel.isHidden = false
    }

    func hideTrackersNameViolation() {
        trackerNameWarningLabel.isHidden = true
    }

    func setCreateButtonEnable() {
        saveButton.backgroundColor = .appEnabledCreateButtonBackground
        saveButton.setTitleColor(.appEnabledCreateButtonText, for: .normal)
    }

    func setCreateButtonDisable() {
        saveButton.backgroundColor = .appGray
        saveButton.setTitleColor(.white, for: .normal)
    }

    func setColor(at indexPath: IndexPath) {
        colorIndexPath = indexPath
    }

    func setEmoji(at indexPath: IndexPath) {
        emojiIndexPath = indexPath
    }

    func setSaveButtonTitle(_ title: String) {
        saveButton.setTitle(title, for: .normal)
    }

    func setTrackerName(_ text: String) {
        trackerName.text = text
    }

    func setTrackerRepeatsCountTitle(_ title: String) {
        trackerRepeatsTitle.text = title
        trackerRepeatsTitle.isHidden = false
        trackerRepeatsFooter.isHidden = false
    }

    func setViewControllerTitle(_ title: String) {
        viewTitle.text = title
    }

    func setupViewsWithTrackerType(trackerType: TrackerType) {
        switch trackerType {
        case .habit:
            trackerButtonsTableView.heightAnchor.constraint(equalToConstant: Constants.trackerButtonsTableViewHeightForHabit).isActive = true
        case .event:
            trackerButtonsTableView.heightAnchor.constraint(equalToConstant: Constants.trackerButtonsTableViewHeightForEvent).isActive = true
        }
    }

    func updateButtonsPanel() {
        let categoryButtonPath = IndexPath(row: 0, section: 0)
        var buttonsPath = [categoryButtonPath]
        if presenter.trackerType == .habit {
            let scheduleButtonPath = IndexPath(row: 1, section: 0)
            buttonsPath.append(scheduleButtonPath)
        }
        trackerButtonsTableView.reloadRows(at: buttonsPath, with: .fade)
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        trackerNameContainer.addArrangedSubview(trackerRepeatsTitle)
        trackerNameContainer.addArrangedSubview(trackerRepeatsFooter)
        trackerNameContainer.addArrangedSubview(trackerName)
        trackerNameContainer.addArrangedSubview(trackerNameWarningLabel)
        buttonsContainer.addArrangedSubview(cancelButton)
        buttonsContainer.addArrangedSubview(saveButton)
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
    @objc private func saveButtonTouchUpInside(_ sender: UIButton) {
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
        presenter.saveTracker { [weak self] result in
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
            trackerNameContainer.leadingAnchor.constraint(equalTo: controlsScrollView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.trackerNameContainerLeadingConstraint),
            trackerNameContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.trackerNameContainerLeadingConstraint),
            /// Заголовок с количеством повторений трекера
            trackerRepeatsTitle.topAnchor.constraint(equalTo: trackerNameContainer.topAnchor),
            trackerRepeatsTitle.leadingAnchor.constraint(equalTo: trackerNameContainer.leadingAnchor),
            trackerRepeatsTitle.trailingAnchor.constraint(equalTo: trackerNameContainer.trailingAnchor),
            trackerRepeatsTitle.heightAnchor.constraint(equalToConstant: Constants.trackerRepeatsTitleHeightConstraint),
            /// Подвал заголовка с количеством повторений трекера
            trackerRepeatsFooter.leadingAnchor.constraint(equalTo: trackerNameContainer.leadingAnchor),
            trackerRepeatsFooter.trailingAnchor.constraint(equalTo: trackerNameContainer.trailingAnchor),
            trackerRepeatsFooter.heightAnchor.constraint(equalToConstant: Constants.trackerRepeatsTitleHeightConstraint),
            /// Поле ввода "Наименование трекера"
            trackerName.leadingAnchor.constraint(equalTo: trackerNameContainer.leadingAnchor),
            trackerName.trailingAnchor.constraint(equalTo: trackerNameContainer.trailingAnchor),
            trackerName.heightAnchor.constraint(equalToConstant: Constants.trackerNameHeightConstraint),
            /// Предупреждение о превышении допустимой длины наименования трекера
            trackerNameWarningLabel.leadingAnchor.constraint(equalTo: trackerNameContainer.leadingAnchor),
            trackerNameWarningLabel.trailingAnchor.constraint(equalTo: trackerNameContainer.trailingAnchor),
            /// Кнопки "Категория" и "Расписание"
            trackerButtonsTableView.topAnchor.constraint(equalTo: trackerNameContainer.bottomAnchor, constant: Constants.trackerButtonsTableViewTopConstraint),
            trackerButtonsTableView.leadingAnchor.constraint(equalTo: controlsScrollView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.trackerButtonsTableViewLeadingConstraint),
            trackerButtonsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.trackerButtonsTableViewLeadingConstraint),
            /// Заголовок коллекции Emoji
            emojiLabel.topAnchor.constraint(equalTo: trackerButtonsTableView.bottomAnchor, constant: Constants.emojiLabelTopConstraint),
            emojiLabel.leadingAnchor.constraint(equalTo: controlsScrollView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.emojiLabelLeadingConstraint),
            /// Коллекция Emoji
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: controlsScrollView.safeAreaLayoutGuide.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: geometricParams.collectionViewHeight),
            /// Заголовок коллекции с цветами
            colorsLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: Constants.colorsLabelTopConstraint),
            colorsLabel.leadingAnchor.constraint(equalTo: controlsScrollView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.colorsLabelLeadingConstraint),
            /// Коллекция с цветами трекера
            colorsCollectionView.topAnchor.constraint(equalTo: colorsLabel.bottomAnchor),
            colorsCollectionView.leadingAnchor.constraint(equalTo: controlsScrollView.safeAreaLayoutGuide.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: geometricParams.collectionViewHeight),
            /// Контейнер для кнопок
            buttonsContainer.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor),
            buttonsContainer.leadingAnchor.constraint(equalTo: controlsScrollView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.buttonsContainerLeadingConstraint),
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
        presenter.processName(sender.text)
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
        guard let trackerType = presenter.trackerType else { return 0 }
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
        presenter.configureTrackerButtonCell(tableView, for: buttonsCell, with: indexPath)
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
            presenter.showCategories()
        } else {
            presenter.showTrackerSchedule()
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
        if collectionView == emojiCollectionView {
            return presenter.emojies.count
        }
        if collectionView == colorsCollectionView {
            return presenter.colors.count
        }
        return 0
    }

    /// Используется для визуального оформления ячейки коллекции
    /// - Parameters:
    ///   - collectionView: ссылка на объект-инициатор события
    ///   - indexPath: индекс ячейки
    /// - Returns: Сконфигурированная и готовая к отображению ячейка коллекци
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewTrackerEmojiCell.Constants.identifier, for: indexPath) as? NewTrackerEmojiCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            presenter.showEmojiCell(for: cell, at: indexPath, withSelection: false)
            return cell
        }
        if collectionView == colorsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewTrackerColorCell.Constants.identifier, for: indexPath) as? NewTrackerColorCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            presenter.showColorCell(for: cell, at: indexPath, withSelection: false)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension NewTrackerViewController: UICollectionViewDelegate {
    /// Обработчик выделения ячейки
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerEmojiCell else { return }
            presenter.showEmojiCell(for: cell, at: indexPath, withSelection: true)
        }
        if collectionView == colorsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerColorCell else { return }
            presenter.showColorCell(for: cell, at: indexPath, withSelection: true)
        }
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
    }

    /// Обработчик снятия выделения с ячейки
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerEmojiCell else { return }
            presenter.showEmojiCell(for: cell, at: indexPath, withSelection: false)
        }
        if collectionView == colorsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerColorCell else { return }
            presenter.showColorCell(for: cell, at: indexPath, withSelection: false)
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
        presenter.processEmoji(newEmoji)
    }
}

// MARK: - NewTrackerColorCellDelegate

extension NewTrackerViewController: NewTrackerColorCellDelegate {
    func colorDidChange(_ newColor: UIColor) {
        presenter.processColor(newColor)
    }
}

// MARK: - UITextFieldDelegate

extension NewTrackerViewController: UITextFieldDelegate {
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
} // swiftlint:disable:this file_length
