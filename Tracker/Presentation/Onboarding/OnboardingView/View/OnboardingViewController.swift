//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 07.09.2024.
//

import UIKit

final class OnboardingViewController: UIPageViewController, OnboardingViewPresenterDelegate {
    // MARK: - Types

    enum Constants {
        /// Параметры индикатора отображаемых страниц
        static let currentPageIndicatorTintColor: UIColor = .appBlackUniversal
        static let pageIndicatorTintColor: UIColor = .appBlackUniversal.withAlphaComponent(0.3)
        /// Параметры кнопки "Вот это технологии!"
        static let launchApplicationButtonFont = GlobalConstants.ypMedium16
        static let launchApplicationButtonTitleColor: UIColor = .white
        static let launchApplicationButtonTitle = L10n.launchApplicationButtonTitle
        static let launchApplicationButtonCornerRadius: CGFloat = 16
        static let launchApplicationButtonBackgroundColor: UIColor = .appBlackUniversal
        static let launchApplicationButtonBottomConstraint: CGFloat = 50
        static let launchApplicationButtonLeadingConstraint: CGFloat = 20
        static let launchApplicationButtonHeightConstraint: CGFloat = 60
        /// Параметры индикатора отображаемых страниц
        static let pageControlBottomConstraint: CGFloat = 24
    }

    // MARK: - Private Properties

    private var presenter: OnboardingViewPresenterProtocol?
    /// Индикатор активной страницы
    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.numberOfPages = presenter?.pages.count ?? 0
        view.currentPage = 0
        view.currentPageIndicatorTintColor = Constants.currentPageIndicatorTintColor
        view.pageIndicatorTintColor = Constants.pageIndicatorTintColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    /// Кнопка перехода к приложению
    private lazy var launchApplicationButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(Constants.launchApplicationButtonTitleColor, for: .normal)
        view.titleLabel?.font = Constants.launchApplicationButtonFont
        view.setTitle(Constants.launchApplicationButtonTitle, for: .normal)
        view.backgroundColor = Constants.launchApplicationButtonBackgroundColor
        view.layer.cornerRadius = Constants.launchApplicationButtonCornerRadius
        view.layer.masksToBounds = true
        view.contentHorizontalAlignment = .center
        view.contentVerticalAlignment = .center
        view.addTarget(self, action: #selector(launchApplicationButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let firstViewController = presenter?.pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        createAndLayoutViews()
    }

    // MARK: - Public Methods

    public func configure(withPresenter presenter: OnboardingViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    // MARK: - Private Methods

    /// Обработчик нажатия на кнопку входа в основную часть приложения
    /// - Parameter sender: объект-инициатор события
    @objc private func launchApplicationButtonTouchUpInside(_ sender: UIButton) {
        UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view).impactOccurred()
        presenter?.didLaunchApplicationButtonPressed()
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.addSubviews([pageControl, launchApplicationButton])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                /// Кнопка "Вот это технологии!"
                launchApplicationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.launchApplicationButtonBottomConstraint),
                launchApplicationButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.launchApplicationButtonLeadingConstraint),
                launchApplicationButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.launchApplicationButtonLeadingConstraint),
                launchApplicationButton.heightAnchor.constraint(equalToConstant: Constants.launchApplicationButtonHeightConstraint),
                /// Индикатор отображаемых страниц
                pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                pageControl.bottomAnchor.constraint(equalTo: launchApplicationButton.topAnchor, constant: -Constants.pageControlBottomConstraint)
            ]
        )
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    /// Возвращает предыдущий вью контроллер относительно отображающегося из массива вью контроллеров UIPageViewController
    /// - Parameters:
    ///   - pageViewController: Элемент управления UIPageViewController
    ///   - viewController: Отображаемый в настоящий момент вью контроллер
    /// - Returns: Вью контроллер, который необходимо отобразить
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let presenter = presenter,
            let viewControllerIndex = presenter.pages.firstIndex(of: viewController)
        else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            guard let last = presenter.pages.last else {
                return nil
            }
            return last
        }

        return presenter.pages[previousIndex]
    }

    /// Возвращает следующий вью контроллер относительно отображаемого в настоящий момент из массива вью контроллеров UIPageViewController
    /// - Parameters:
    ///   - pageViewController: Элемент управления UIPageViewController
    ///   - viewController: Отображаемый в настоящий момент вью контроллер
    /// - Returns: Вью контроллер, который необходимо отобразить
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let presenter = presenter,
            let viewControllerIndex = presenter.pages.firstIndex(of: viewController)
        else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < presenter.pages.count else {
            guard let first = presenter.pages.first else {
                return nil
            }
            return first
        }

        return presenter.pages[safe: nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    /// Вызывается по окончании анимации перелистывания страниц UIPageViewController, используется для изменения индекса текущего экрана онбординга в UIPageControl
    /// - Parameters:
    ///   - pageViewController: Объект-иницатор события
    ///   - finished: Индикатор окончания анимации перелистывания
    ///   - previousViewControllers: Массив вью контроллеров до перехода
    ///   - completed: Истина, если пользователь завершил жест перелистывания; Ложь в противном случае
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let presenter = presenter,
            let currentViewController = pageViewController.viewControllers?.first,
            let viewControllerIndex = presenter.pages.firstIndex(of: currentViewController)
        else {
            return
        }

        pageControl.currentPage = viewControllerIndex
    }
}
