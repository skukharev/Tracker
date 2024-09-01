//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 27.07.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        window.backgroundColor = .appWhite
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
