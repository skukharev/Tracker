//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 09.09.2024.
//

import UIKit

final class CategoriesViewController: UIViewController {
    // MARK: - Types

    /// Настройки дизайна
    enum Constants {
        static let categoriesStubImageName = "TrackersStub"
        static let viewTitleFont = GlobalConstants.ypMedium16
        static let viewTitleTextColor = UIColor.appBlack
        static let viewTitleText = "Категория"
        static let viewTitleTopConstraint: CGFloat = 27
        static let categoriesTableViewTopConstraint: CGFloat = 38
        static let categoriesTableViewLeadingConstraint: CGFloat = 16
        static let categoriesTableViewSeparatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let categoriesTableViewCornerRadius: CGFloat = 16
        static let categoriesTableViewRowHeight: CGFloat = 75
        static let categoriesTableViewEditActionText = "Редактировать"
        static let categoriesTableViewDeleteActionText = "Удалить"
        static let addCategoryButtonTitleFont = GlobalConstants.ypMedium16
        static let addCategoryButtonTitle = "Добавить категорию"
        static let addCategoryButtonTitleColor = UIColor.appWhite
        static let addCategoryButtonBackgroundColor = UIColor.appBlack
        static let addCategoryButtonCornerRadius: CGFloat = 16
        static let addCategoryButtonLeadingConstraint: CGFloat = 20
        static let addCategoryButtonBottomConstraint: CGFloat = 16
        static let addCategoryButtonHeightConstraint: CGFloat = 60
        static let categoriesStubImageLabelFont = GlobalConstants.ypMedium12
        static let categoriesStubImageLabelTextColor = UIColor.appBlack
        static let categoriesStubImageLabelText = "Привычки и события можно\nобъединить по смыслу"
        static let categoriesStubImageWidthConstraint: CGFloat = 80
        static let categoriesStubImageLabelTopConstraint: CGFloat = 8
        static let deleteCategoryDenyAlertTitle = "Действие ограничено"
        static let deleteCategoryDenyAlertMessage = "Для категории определены трекеры, поэтому её удаление ограничено"
        static let confirmCategoryDeleteAlertTitle = "Подтвердите действие"
        static let confirmCategoryDeleteAlertMessage = "Вы действительно хотите удалить категорию?"
        static let confirmCategoryDeleteAlertYesButtonText = "Да"
        static let confirmCategoryDeleteAlertNoButtonText = "Нет"
    }

    // MARK: - Private Properties

    /// Ассоциированная View Model
    private var viewModel: CategoriesViewModelProtocol?
    /// Заголовок окна
    private lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.viewTitleFont
        view.textColor = Constants.viewTitleTextColor
        view.text = Constants.viewTitleText
        return view
    }()
    /// Табличное представление со списком категорий
    private lazy var categoriesTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorInset = Constants.categoriesTableViewSeparatorInset
        view.allowsSelection = true
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = Constants.categoriesTableViewCornerRadius
        view.layer.masksToBounds = true
        view.rowHeight = Constants.categoriesTableViewRowHeight
        view.estimatedRowHeight = view.rowHeight
        return view
    }()
    /// Кнопка "Добавить категорию"
    private lazy var addCategoryButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = Constants.addCategoryButtonTitleFont
        view.setTitle(Constants.addCategoryButtonTitle, for: .normal)
        view.setTitleColor(Constants.addCategoryButtonTitleColor, for: .normal)
        view.backgroundColor = Constants.addCategoryButtonBackgroundColor
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = Constants.addCategoryButtonCornerRadius
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(addCategoryButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    /// Изображение заглушки списка категорий
    private lazy var categoriesStubImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        guard let stubImage = UIImage(named: Constants.categoriesStubImageName) else {
            assertionFailure("Ошибка загрузки логотипа заглушки")
            return view
        }
        view.image = stubImage
        view.contentMode = .center
        return view
    }()
    /// Текст заглушки списка категорий
    private lazy var categoriesStubImageLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.categoriesStubImageLabelFont
        view.textColor = Constants.categoriesStubImageLabelTextColor
        view.text = Constants.categoriesStubImageLabelText
        view.numberOfLines = 2
        view.textAlignment = .center
        return view
    }()
    /// Переменная хранит текущее количество категорий в табличном представлении и используется для изменения высоты табличного представления со списком категорий
    private var categoriesCount: Int = 0 {
        didSet {
            if oldValue != categoriesCount {
                let allowedCategoriesCount = min(6, categoriesCount)
                let newTableViewHeight = CGFloat(allowedCategoriesCount) * Constants.categoriesTableViewRowHeight
                if let deletingConstraint = categoriesTableView.constraints.first(where: { $0.firstAttribute == .height }) {
                    deletingConstraint.isActive = false
                    categoriesTableView.removeConstraint(deletingConstraint)
                }
                categoriesTableView.heightAnchor.constraint(equalToConstant: newTableViewHeight).isActive = true
                categoriesTableView.layoutIfNeeded()
            }
        }
    }

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
        categoriesTableView.register(CategoryCell.classForCoder(), forCellReuseIdentifier: CategoryCell.Constants.identifier)
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
    }

    // MARK: - Public Methods

    /// Устанавливает связь между View и View Model, настраивает binding между двумя классами
    /// - Parameter viewModel: экземпляр View Model
    func initialize(viewModel: CategoriesViewModelProtocol) {
        self.viewModel = viewModel
        bind()
    }

    // MARK: - Private Methods

    /// Обработчик нажатия на кнопку "Добавить категорию"
    /// - Parameter sender: инициатор события
    @objc private func addCategoryButtonTouchUpInside(_ sender: UIButton) {
        showCategoryEditScreen()
    }

    private func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.onCategoriesListChange = { [weak self] update in
            guard let self = self else { return }
            self.categoriesTableView.performBatchUpdates {
                if let insertedIndexes = update.insertedIndexes {
                    let insertedIndex = insertedIndexes.map { IndexPath(row: $0, section: 0) }
                    self.categoriesTableView.insertRows(at: insertedIndex, with: .automatic)
                }
                if let deletedIndexes = update.deletedIndexes {
                    let deletedIndex = deletedIndexes.map { IndexPath(row: $0, section: 0) }
                    self.categoriesTableView.deleteRows(at: deletedIndex, with: .automatic)
                }
            }
        }
        viewModel.onNeedReloadCategoriesList = { [weak self] _ in
            self?.categoriesTableView.reloadData()
        }
    }

    /// Используется для подтверждения пользователем и последующего удаления категории
    /// - Parameter categoryName: Наименование удаляемой категории
    private func confirmCategoryDelete(withCategory categoryName: String) {
        let alertView = UIAlertController(
            title: Constants.confirmCategoryDeleteAlertTitle,
            message: Constants.confirmCategoryDeleteAlertMessage,
            preferredStyle: .alert
        )
        alertView.addAction(UIAlertAction(title: Constants.confirmCategoryDeleteAlertNoButtonText, style: .cancel))
        alertView.addAction(
            UIAlertAction(
                title: Constants.confirmCategoryDeleteAlertYesButtonText,
                style: .destructive) { [weak self] _ in
                    self?.viewModel?.deleteCategory(withCategory: categoryName)
            }
        )
        alertView.view.accessibilityIdentifier = "confirmCategoryDeletePresenter"
        present(alertView, animated: true)
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        view.addSubviews([viewTitle, categoriesTableView, addCategoryButton])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
            /// Заголовок окна
            viewTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.viewTitleTopConstraint),
            viewTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            viewTitle.heightAnchor.constraint(equalToConstant: viewTitle.intrinsicContentSize.height),
            /// Табличное представление со списком категорий
            categoriesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.categoriesTableViewLeadingConstraint),
            categoriesTableView.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: Constants.categoriesTableViewTopConstraint),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.categoriesTableViewLeadingConstraint),
            categoriesTableView.heightAnchor.constraint(equalToConstant: Constants.categoriesTableViewRowHeight),
            /// Кнопка "Добавить категорию"
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.addCategoryButtonLeadingConstraint),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.addCategoryButtonLeadingConstraint),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.addCategoryButtonBottomConstraint),
            addCategoryButton.heightAnchor.constraint(equalToConstant: Constants.addCategoryButtonHeightConstraint)
            ]
        )
    }

    /// Скрывает табличное представление со списком категорий
    private func hideCategoriesList() {
        categoriesTableView.isHidden = true
    }

    /// Скрывает заглушку пустого списка категорий
    private func hideCategoriesListStub() {
        categoriesStubImage.isHidden = true
        categoriesStubImageLabel.isHidden = true
    }

    /// Отображает табличное представление со списком категорий
    private func showCategoriesList() {
        categoriesTableView.isHidden = false
    }

    /// Отображает заглушку пустого списка категорий
    private func showCategoriesListStub() {
        if !view.subviews.contains(categoriesStubImage) {
            view.addSubviews([categoriesStubImage, categoriesStubImageLabel])
            NSLayoutConstraint.activate(
                [
                    // Заглушка
                    categoriesStubImage.widthAnchor.constraint(equalToConstant: Constants.categoriesStubImageWidthConstraint),
                    categoriesStubImage.heightAnchor.constraint(equalToConstant: Constants.categoriesStubImageWidthConstraint),
                    categoriesStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                    categoriesStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                    // Текст заглушки
                    categoriesStubImageLabel.topAnchor.constraint(equalTo: categoriesStubImage.bottomAnchor, constant: Constants.categoriesStubImageLabelTopConstraint),
                    categoriesStubImageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
                ]
            )
        }
        categoriesStubImage.isHidden = false
        categoriesStubImageLabel.isHidden = false
    }

    /// Отображает алерт с запретом удаления категории с подчинёнными трекерами
    private func showDeleteCategoryDenyAlert() {
        let alertView = UIAlertController(
            title: Constants.deleteCategoryDenyAlertTitle,
            message: Constants.deleteCategoryDenyAlertMessage,
            preferredStyle: .alert
        )
        alertView.addAction(UIAlertAction(title: "OK", style: .default))
        alertView.view.accessibilityIdentifier = "showDeleteCategoryDenyAlertPresenter"
        present(alertView, animated: true)
    }

    /// Отображает экран создания/редактирования категории
    /// - Parameter category: модель с заполненными реквизитами категории. Если модель пустая, то отображается экран создания категории; в противном случае - экран редактирования категории
    private func showCategoryEditScreen(withCategory category: NewCategoryModel? = nil) {
        guard let viewModel = viewModel else { return }
        let targetViewController = NewCategoryScreenAssembley.build(withDelegate: viewModel, withCategory: category)
        let router = Router(viewController: self, targetViewController: targetViewController)
        router.showNext(dismissCurrent: false)
    }
}

// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    /// Возвращает количество категорий трекеров в базе данных
    /// - Parameters:
    ///   - tableView: табличное представление со списком категорий
    ///   - section: индекс секции, для которой запрашивается количество категорий. Здесь всегда 0
    /// - Returns: Количество кнопок на панели
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoriesCount = viewModel?.сategoiresCount() ?? 0
        if categoriesCount == 0 {
            showCategoriesListStub()
            hideCategoriesList()
        } else {
            showCategoriesList()
            hideCategoriesListStub()
        }
        return categoriesCount
    }

    /// Используется для определения ячейки, которую требуется отобразить в заданной позиции панели кнопок экрана редактирования трекера
    /// - Parameters:
    ///   - tableView: табличное представление с кнопками
    ///   - indexPath: индекс отображаемой кнопки
    /// - Returns: сконфигурированную и готовую к показу кнопку
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.Constants.identifier, for: indexPath) as? CategoryCell else {
            assertionFailure("Ошибка приведения типов ячеек табличного представления со списком трекеров")
            return UITableViewCell()
        }
        guard let categoryCellModel = viewModel?.category(at: indexPath) else {
            assertionFailure("Ошибка получения наименования категории по индексу \(indexPath)")
            return cell
        }
        cell.configureCell(with: categoryCellModel)
        if indexPath == tableView.lastCellIndexPath {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width + 1, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    /// Обработчик выделения заданной ячейки из списка категорий
    /// - Parameters:
    ///   - tableView: табличное представление со списком категорий
    ///   - indexPath: индекс выбранной категории
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        viewModel?.didSelectCategory(at: indexPath)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: Constants.categoriesTableViewEditActionText) { [weak self] _ in
                guard
                    let viewModel = self?.viewModel,
                    let categoryCellModel = viewModel.category(at: indexPath)
                else { return }
                self?.showCategoryEditScreen(withCategory: NewCategoryModel(name: categoryCellModel.name))
            }
            let deleteAction = UIAction(title: Constants.categoriesTableViewDeleteActionText, attributes: .destructive) { [weak self] _ in
                guard
                    let self = self,
                    let viewModel = self.viewModel,
                    let categoryCellModel = viewModel.category(at: indexPath)
                else { return }

                if !viewModel.deleteCategoryRequest(withCategory: categoryCellModel.name) {
                    self.showDeleteCategoryDenyAlert()
                    return
                }
                self.confirmCategoryDelete(withCategory: categoryCellModel.name)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
        return configuration
    }
}
