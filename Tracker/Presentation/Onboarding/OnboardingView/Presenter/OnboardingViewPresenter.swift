//
//  OnboardingViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 08.09.2024.
//

import UIKit

final class OnboardingViewPresenter: OnboardingViewPresenterProtocol {
    // MARK: - Public Properties

    weak var viewController: (any OnboardingViewPresenterDelegate)?

    var pages: [UIViewController] = []

    // MARK: - Initializers

    init(pages: [UIViewController]) {
        self.pages = pages
    }

    convenience init() {
        let page1ViewController = OnboardingPageViewController()
        page1ViewController.showOnboardingPage(
            withModel: OnboardingPage(
                image: GlobalConstants.onboardingPage1Image,
                title: "Отслеживайте только то, что хотите"
            )
        )
        let page2ViewController = OnboardingPageViewController()
        page2ViewController.showOnboardingPage(
            withModel: OnboardingPage(
                image: GlobalConstants.onboardingPage2Image,
                title: "Даже если это не литры воды и йога"
            )
        )
        self.init(pages: [page1ViewController, page2ViewController])
    }

    // MARK: - Public Methods

    func didLaunchApplicationButtonPressed() {
        guard let viewController = viewController as? UIViewController else { return }
        let targetViewController = TrackersScreenAssembley.build()
        let router = Router(viewController: viewController, targetViewController: targetViewController)
        router.showNext()
    }
}