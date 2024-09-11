//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.09.2024.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    // MARK: - Types

    enum Constants {
        static let viewTitleFont = GlobalConstants.ypMedium16
        static let viewTitleTextColor = UIColor.appBlack
        static let viewTitleTextForNewCategory = "Новая категория"
        static let viewTitleTextForEditCategory = "Редактирование категории"
        static let viewTitleTopConstraint: CGFloat = 27
        static let categoryNameTextColor = UIColor.appBlack
        static let categoryNameBackgroundColor = UIColor.appBackground
        static let categoryNamePlaceholder = "Введите название категории"
        static let categoryNameCornerRadius: CGFloat = 16
        static let categoryNameViewFrame = CGRect(x: 0, y: 0, width: 16, height: 10)
        static let categoryNameTopConstraint: CGFloat = 38
        static let categoryNameLeadingConstraint: CGFloat = 16
        static let categoryNameHeightConstraint: CGFloat = 75
        static let saveButtonTitle = "Готово"
        static let saveButtonTitleFont = GlobalConstants.ypMedium16
        static let saveButtonCornerRadius: CGFloat = 16
        static let saveButtonTitleColorForDisabled = UIColor.white
        static let saveButtonTitleColorForEnabled = UIColor.appWhite
        static let saveButtonBackgroundColorForDisabled = UIColor.appGray
        static let saveButtonBackgroundColorForEnabled = UIColor.appBlack
        static let saveButtonLeadingConstraint: CGFloat = 20
        static let saveButtonBottomConstraint: CGFloat = 16
        static let saveButtonHeightConstraint: CGFloat = 60
        static let categoryNameWarningLabelTextColor = UIColor.appRed
        static let categoryNameWarningLabelFont = GlobalConstants.ypRegular17
        static let categoryNameWarningLabelTopConstraint: CGFloat = 8
    }

    // MARK: - Private Properties

    /// Ассоциированная View Model
    private var viewModel: NewCategoryViewModelProtocol?
    /// Заголовок окна
    private lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.viewTitleFont
        view.textColor = Constants.viewTitleTextColor
        return view
    }()
    /// Поле ввода "Наименование категории"
    private lazy var categoryName: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = Constants.categoryNameTextColor
        view.backgroundColor = Constants.categoryNameBackgroundColor
        view.placeholder = Constants.categoryNamePlaceholder
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .leading
        view.layer.cornerRadius = Constants.categoryNameCornerRadius
        view.layer.masksToBounds = true
        view.leftViewMode = .always
        view.leftView = UIView(frame: Constants.categoryNameViewFrame)
        view.clearButtonMode = .whileEditing
        view.returnKeyType = .done
        view.delegate = self
        view.addTarget(self, action: #selector(categoryNameEditingDidChange(_:)), for: .editingChanged)
        return view
    }()
    /// Предупреждение о существовании в базе данных категории с заданным наименованием
    private lazy var categoryNameWarningLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = Constants.categoryNameWarningLabelTextColor
        view.font = Constants.categoryNameWarningLabelFont
        view.numberOfLines = 2
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()
    /// Кнопка записи категории трекера в базу данных
    private lazy var saveButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(Constants.saveButtonTitleColorForDisabled, for: .disabled)
        view.setTitleColor(Constants.saveButtonTitleColorForEnabled, for: .normal)
        view.backgroundColor = Constants.saveButtonBackgroundColorForDisabled
        view.setTitle(Constants.saveButtonTitle, for: .normal)
        view.titleLabel?.font = Constants.saveButtonTitleFont
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = Constants.saveButtonCornerRadius
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(saveButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
    }

    // MARK: - Public Methods

    /// Устанавливает связь между View и View Model, настраивает binding между двумя классами
    /// - Parameter viewModel: экземпляр View Model
    func initialize(viewModel: NewCategoryViewModelProtocol, withCategory category: NewCategoryModel?) {
        self.viewModel = viewModel
        bind()
        viewModel.category = category
    }

    // MARK: - Private Methods

    /// Используется для адаптации внешнего вида кнопки сохранения категории
    /// - Parameter isEnabled: Истина, если кнопку необходимо разблокировать; Ложь - в противном случае
    private func adjustSaveButtonState(_ isEnabled: Bool) {
        saveButton.isUserInteractionEnabled = isEnabled
        saveButton.backgroundColor = isEnabled ? Constants.saveButtonBackgroundColorForEnabled : Constants.saveButtonBackgroundColorForDisabled
    }

    private func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.onCategoryChange = { [weak self] category in
            guard let self = self else { return }
            if category != nil {
                self.viewTitle.text = Constants.viewTitleTextForEditCategory
                self.categoryName.text = category?.name
                if let categoryName = self.categoryName.text {
                    viewModel.didCategoryNameEnter(categoryName)
                }
            } else {
                self.viewTitle.text = Constants.viewTitleTextForNewCategory
            }
        }
        viewModel.onSaveCategoryAllowedStateChange = { [weak self] isSaveAllowed in
            self?.adjustSaveButtonState(isSaveAllowed)
        }
        viewModel.onErrorStateChange = { [weak self] errorText in
            self?.showError(errorText)
        }
    }

    /// Обработчик изменения значения наименования категории трекеров
    /// - Parameter sender: Объект-инициатор события
    @objc private func categoryNameEditingDidChange(_ sender: UITextField) {
        viewModel?.didCategoryNameEnter(sender.text)
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        view.addSubviews([viewTitle, categoryName, categoryNameWarningLabel, saveButton])
        setupConstraints()
    }

    /// Обработчик нажатия на кнопку сохранения категории трекеров
    /// - Parameter sender: Объект-инициатор события
    @objc private func saveButtonTouchUpInside(_ sender: UIButton) {
        guard let categoryName = categoryName.text else { return }
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
        viewModel?.saveCategory(withName: categoryName)
        dismiss(animated: true)
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                /// Заголовок окна
                viewTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.viewTitleTopConstraint),
                viewTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                viewTitle.heightAnchor.constraint(equalToConstant: viewTitle.intrinsicContentSize.height),
                /// Поле ввода наименования категории
                categoryName.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: Constants.categoryNameTopConstraint),
                categoryName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.categoryNameLeadingConstraint),
                categoryName.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.categoryNameLeadingConstraint),
                categoryName.heightAnchor.constraint(equalToConstant: Constants.categoryNameHeightConstraint),
                /// Текст для отображения ошибок
                categoryNameWarningLabel.topAnchor.constraint(equalTo: categoryName.bottomAnchor, constant: Constants.categoryNameWarningLabelTopConstraint),
                categoryNameWarningLabel.leadingAnchor.constraint(equalTo: categoryName.leadingAnchor),
                categoryNameWarningLabel.trailingAnchor.constraint(equalTo: categoryName.trailingAnchor),
                /// Кнопка "Готово"
                saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.saveButtonLeadingConstraint),
                saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.saveButtonLeadingConstraint),
                saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.saveButtonBottomConstraint),
                saveButton.heightAnchor.constraint(equalToConstant: Constants.saveButtonHeightConstraint)
            ]
        )
    }

    /// Используется для отображения предупреждений при сохранении категории трекеров
    /// - Parameter errorText: Текст ошибки
    private func showError(_ errorText: String?) {
        categoryNameWarningLabel.isHidden = errorText == nil
        categoryNameWarningLabel.text = errorText
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
