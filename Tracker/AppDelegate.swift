//
//  AppDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 27.07.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /// Регистрация трансформеров нестандартных типов данных Core Data
        UIColorToDataTransformer.register()
        _ = Database.shared.persistentContainer.viewContext
        /// Подключение Yandex.Metrica
        AnalyticsService.activate()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
