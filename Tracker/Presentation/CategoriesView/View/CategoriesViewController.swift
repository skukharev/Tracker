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
        static let viewTitleFont = GlobalConstants.ypMedium16
        static let viewTitleTextColor = UIColor.appBlack
        static let cvcViewTitleText = L10n.cvcViewTitleText
        static let viewTitleTopConstraint: CGFloat = 27
        static let categoriesTableViewTopConstraint: CGFloat = 38
        static let categoriesTableViewLeadingConstraint: CGFloat = 16
        static let categoriesTableViewSeparatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let categoriesTableViewCornerRadius: CGFloat = 16
        static let categoriesTableViewRowHeight: CGFloat = 75
        static let categoriesTableViewEditActionText = L10n.categoriesTableViewEditActionText
        static let categoriesTableViewDeleteActionText = L10n.categoriesTableViewDeleteActionText
        static let addCategoryButtonTitleFont = GlobalConstants.ypMedium16
        static let addCategoryButtonTitle = L10n.addCategoryButtonTitle
        static let addCategoryButtonTitleColor = UIColor.appWhite
        static let addCategoryButtonBackgroundColor = UIColor.appBlack
        static let addCategoryButtonCornerRadius: CGFloat = 16
        static let addCategoryButtonLeadingConstraint: CGFloat = 20
        static let addCategoryButtonBottomConstraint: CGFloat = 16
        static let addCategoryButtonHeightConstraint: CGFloat = 60
        static let categoriesStubImageLabelFont = GlobalConstants.ypMedium12
        static let categoriesStubImageLabelTextColor = UIColor.appBlack
        static let categoriesStubImageLabelText = L10n.categoriesStubImageLabelText
        static let categoriesStubImageWidthConstraint: CGFloat = 80
        static let categoriesStubImageLabelTopConstraint: CGFloat = 8
        static let deleteCategoryDenyAlertTitle = L10n.deleteCategoryDenyAlertTitle
        static let deleteCategoryDenyAlertMessage = L10n.deleteCategoryDenyAlertMessage
        static let confirmCategoryDeleteAlertMessage = L10n.confirmCategoryDeleteAlertMessage
        static let confirmCategoryDeleteAlertYesButtonText = L10n.confirmCategoryDeleteAlertYesButtonText
        static let confirmCategoryDeleteAlertNoButtonText = L10n.confirmCategoryDeleteAlertNoButtonText
        static let buttonOKTitle = L10n.buttonOKTitle
    }

    // MARK: - Private Properties

    private var viewModel: CategoriesViewModelProtocol?
    private lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.viewTitleFont
        view.textColor = Constants.viewTitleTextColor
        view.text = Constants.cvcViewTitleText
        return view
    }()
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
    private lazy var categoriesStubImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = Asset.Images.trackersStub.image
        view.contentMode = .center
        return view
    }()
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

    func initialize(viewModel: CategoriesViewModelProtocol) {
        self.viewModel = viewModel
        bind()
    }

    // MARK: - Private Methods

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
                if let updatedIndexes = update.updatedIndexes {
                    let updatedIndex = updatedIndexes.map { IndexPath(row: $0, section: 0) }
                    self.categoriesTableView.reloadRows(at: updatedIndex, with: .automatic)
                }
            }
        }
    }

    private func confirmCategoryDelete(withCategory categoryName: String) {
        let alertView = UIAlertController(
            title: nil,
            message: Constants.confirmCategoryDeleteAlertMessage,
            preferredStyle: .actionSheet
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

    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        view.addSubviews([viewTitle, categoriesTableView, addCategoryButton])
        setupConstraints()
    }

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

    private func hideCategoriesList() {
        categoriesTableView.isHidden = true
    }

    private func hideCategoriesListStub() {
        categoriesStubImage.isHidden = true
        categoriesStubImageLabel.isHidden = true
    }

    private func showCategoriesList() {
        categoriesTableView.isHidden = false
    }

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

    private func showDeleteCategoryDenyAlert() {
        let alertView = UIAlertController(
            title: Constants.deleteCategoryDenyAlertTitle,
            message: Constants.deleteCategoryDenyAlertMessage,
            preferredStyle: .alert
        )
        alertView.addAction(UIAlertAction(title: Constants.buttonOKTitle, style: .default))
        alertView.view.accessibilityIdentifier = "showDeleteCategoryDenyAlertPresenter"
        present(alertView, animated: true)
    }

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

    /// Обработчик отображения контекстного меню для заданной ячейки из списка категорий
    /// - Parameters:
    ///   - tableView: табличное представление со списком категорий
    ///   - indexPath: индекс выбранной ячейки с категорией
    ///   - point: Точка вызова контекстного меню
    /// - Returns: Сконфигурированное к показу контекстное меню
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
