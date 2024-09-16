//
//  OnboardingViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 08.09.2024.
//

import UIKit

final class OnboardingViewPresenter: OnboardingViewPresenterProtocol {
    // MARK: - Types

    enum Constants {
        static let onboardingPage1Title = NSLocalizedString("onboardingPage1Title", comment: "")
        static let onboardingPage2Title = NSLocalizedString("onboardingPage2Title", comment: "")
    }

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
                title: Constants.onboardingPage1Title
            )
        )
        let page2ViewController = OnboardingPageViewController()
        page2ViewController.showOnboardingPage(
            withModel: OnboardingPage(
                image: GlobalConstants.onboardingPage2Image,
                title: Constants.onboardingPage2Title
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
