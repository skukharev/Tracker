//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation
import UIKit

final class StatisticsViewController: UIViewController, StatisticsViewPresenterDelegate {
    // MARK: - Types

    enum Constants {
        static let сellParams = UICollectionViewCellGeometricParams(cellCount: 1, topInset: 0, leftInset: 0, rightInset: 0, bottomInset: 0, cellSpacing: 0, lineSpacing: 12, cellHeight: 90)
        static let statisticsStubImageLabelText = L10n.statisticsStubImageLabelText
        static let statisticsStubImageWidthConstraint: CGFloat = 80
        static let statisticsStubImageLabelTopConstraint: CGFloat = 8
        static let statisticsCollectionLeadingConstraint: CGFloat = 16
        static let statisticsCollectionTopConstraint: CGFloat = 69
    }

    // MARK: - Private Properties
    private var presenter: StatisticsViewPresenterProtocol?

    private lazy var statisticsStubImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = Asset.Images.statisticsStub.image
        image.contentMode = .center
        return image
    }()
    private lazy var statisticsStubImageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = GlobalConstants.ypMedium12
        label.textColor = .appBlack
        label.text = Constants.statisticsStubImageLabelText
        return label
    }()
    private lazy var statisticsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .appWhite
        return collectionView
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
        presenter?.calculateStatistics()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.calculateStatistics()
    }

    // MARK: - Public Methods

    /// Используется для связи вью контроллера с презентером
    /// - Parameter presenter: презентер вью контроллера
    func configure(_ presenter: StatisticsViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    func hideStatisticsStub() {
        if view.subviews.contains(statisticsStubImage) {
            statisticsStubImage.isHidden = true
        }
        if view.subviews.contains(statisticsStubImageLabel) {
            statisticsStubImageLabel.isHidden = true
        }
        statisticsCollection.reloadData()
        statisticsCollection.isHidden = false
    }

    func showStatisticsStub() {
        if !view.subviews.contains(statisticsStubImage) {
            view.addSubviews([statisticsStubImage, statisticsStubImageLabel])
            NSLayoutConstraint.activate(
                [
                    // Заглушка
                    statisticsStubImage.widthAnchor.constraint(equalToConstant: Constants.statisticsStubImageWidthConstraint),
                    statisticsStubImage.heightAnchor.constraint(equalToConstant: Constants.statisticsStubImageWidthConstraint),
                    statisticsStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                    statisticsStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                    // Текст заглушки
                    statisticsStubImageLabel.topAnchor.constraint(equalTo: statisticsStubImage.bottomAnchor, constant: Constants.statisticsStubImageLabelTopConstraint),
                    statisticsStubImageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
                ]
            )
        }
        statisticsStubImage.isHidden = false
        statisticsStubImageLabel.isHidden = false
        statisticsCollection.isHidden = true
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        /// Панель навигации
        navigationItem.title = L10n.statisticsTabBarItemTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        /// Элементы управления
        view.addSubviews([statisticsCollection])
        statisticsCollection.register(StatisticsCollectionViewCell.self, forCellWithReuseIdentifier: StatisticsCollectionViewCell.Constants.identifier)
        statisticsCollection.dataSource = self
        statisticsCollection.delegate = self
        /// Разметка элементов управления
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                statisticsCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.statisticsCollectionLeadingConstraint),
                statisticsCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.statisticsCollectionTopConstraint),
                statisticsCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.statisticsCollectionLeadingConstraint),
                statisticsCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
    }
}

// MARK: - UICollectionViewDataSource

extension StatisticsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.statisticsCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StatisticsCollectionViewCell.Constants.identifier,
            for: indexPath) as? StatisticsCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        presenter?.showCell(for: cell, with: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    /// Задаёт размеры отображаемой ячейки в коллекции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - indexPath: Индекс ячейки в коллекции
    /// - Returns: Размер ячейки 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - Constants.сellParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(Constants.сellParams.cellCount)
        return CGSize(width: cellWidth, height: Constants.сellParams.cellHeight)
    }

    /// Задаёт размеры отступов ячеек заданной секции от границ коллекции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции
    /// - Returns: Размеры отступов ячеек секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: Constants.сellParams.topInset,
            left: Constants.сellParams.leftInset,
            bottom: Constants.сellParams.bottomInset,
            right: Constants.сellParams.rightInset
        )
    }

    /// Задаёт размеры отступов между строками ячеек заданной секции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции
    /// - Returns: Размер отступа между строками ячеек заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.сellParams.lineSpacing
    }

    /// Задаёт размер отступов между ячейками одной строки заданной секции
    /// - Parameters:
    ///   - collectionView: Элемент управления
    ///   - collectionViewLayout: Объект с типом размещения элементов внутри коллекции
    ///   - section: Индекс секции
    /// - Returns: Размер отступа между ячейками одной строки заданной секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.сellParams.cellSpacing
    }
}
