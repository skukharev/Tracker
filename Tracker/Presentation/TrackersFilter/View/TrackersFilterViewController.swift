//
//  TrackersFilterViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.09.2024.
//

import UIKit

final class TrackersFilterViewController: UIViewController, TrackersFilterViewControllerProtocol {
    // MARK: - Types

    enum Constants {
        static let viewTitleFont = GlobalConstants.ypMedium16
        static let viewTitleTextColor = UIColor.appBlack
        static let viewTitleText = L10n.trackerFiltersViewControllerTitle
        static let viewTitleTopConstraint: CGFloat = 27
        static let filtersTableViewSeparatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let filtersTableViewCornerRadius: CGFloat = 16
        static let filtersTableViewRowHeight: CGFloat = 75
        static let filtersTableViewLeadingConstraint: CGFloat = 16
        static let filtersTableViewTopConstraint: CGFloat = 38
        static let filtersTableViewHeightConstraint: CGFloat = 4 * filtersTableViewRowHeight
    }

    // MARK: - Public Properties

    var presenter: TrackersFilterViewPresenterProtocol?

    // MARK: - Private Properties

    /// Заголовок окна
    private lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.viewTitleFont
        view.textColor = Constants.viewTitleTextColor
        view.text = Constants.viewTitleText
        return view
    }()
    /// Cписок фильтров
    private lazy var filtersTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorInset = Constants.filtersTableViewSeparatorInset
        view.allowsSelection = true
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = Constants.filtersTableViewCornerRadius
        view.layer.masksToBounds = true
        view.rowHeight = Constants.filtersTableViewRowHeight
        view.estimatedRowHeight = view.rowHeight
        return view
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
        filtersTableView.register(FilterCell.classForCoder(), forCellReuseIdentifier: FilterCell.Constants.identifier)
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
    }

    // MARK: - Punlic Methods

    func configure(_ presenter: TrackersFilterViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    // MARK: - Private Methods

    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        view.addSubviews([viewTitle, filtersTableView])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                /// Заголовок окна
                viewTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.viewTitleTopConstraint),
                viewTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                viewTitle.heightAnchor.constraint(equalToConstant: viewTitle.intrinsicContentSize.height),
                /// Табличное представление со списком фильтров
                filtersTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.filtersTableViewLeadingConstraint),
                filtersTableView.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: Constants.filtersTableViewTopConstraint),
                filtersTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.filtersTableViewLeadingConstraint),
                filtersTableView.heightAnchor.constraint(equalToConstant: Constants.filtersTableViewHeightConstraint)
            ]
        )
    }
}

// MARK: - UITableViewDataSource

extension TrackersFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackersFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.Constants.identifier, for: indexPath) as? FilterCell else {
            assertionFailure("Ошибка приведения типов ячеек табличного представления со списком фильтров")
            return UITableViewCell()
        }
        guard let filterCellModel = presenter?.trackersFilter(at: indexPath) else {
            assertionFailure("Ошибка получения наименования фильтра трекеров по индексу \(indexPath)")
            return cell
        }
        cell.configureCell(with: filterCellModel)
        if indexPath == tableView.lastCellIndexPath {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width + 1, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackersFilterViewController: UITableViewDelegate {
    /// Обработчик выделения заданной ячейки в табличном представлении со списком фильтров трекеров
    /// - Parameters:
    ///   - tableView: табличное представление со списком фильтров трекеров
    ///   - indexPath: индекс выбранной ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        presenter?.didSelectTrackersFilter(at: indexPath)
    }
}
