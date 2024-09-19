//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Сергей Кухарев on 19.09.2024.
//

import Foundation
import AppMetricaCore

typealias AnalyticsEventParam = [AnyHashable: Any]

enum AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: GlobalConstants.yandexMetrikaApi) else {
            assertionFailure("Ошибка инициализации Yandex.Metrica")
            return
        }

        AppMetrica.activate(with: configuration)
    }

    static func report(event: String, params: AnalyticsEventParam) {
        AppMetrica.reportEvent(name: event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}
