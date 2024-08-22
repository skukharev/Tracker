//
//  UIDevice+Extensions.swift
//  Tracker
//
//  Created by Сергей Кухарев on 20.08.2024.
//

import UIKit

/// Типы устройств Apple
public enum DeviceModel {
    case iPhoneSE
    case iPhoneSE2
    case iPhoneSE3
    case unrecognized
}

public extension UIDevice {
    /// Тип устройства, на котором запущено приложение
    var type: DeviceModel {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        func mapToDevice(identifier: String) -> DeviceModel {
            switch identifier {
            case "iPhone8,4":
                return .iPhoneSE
            case "iPhone12,8":
                return .iPhoneSE2
            case "iPhone14,6":
                return .iPhoneSE3
            case "i386", "x86_64", "arm64":
                return mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS")
            default:
                return .unrecognized
            }
        }
        return mapToDevice(identifier: identifier)
    }
    /// Индикатор запуска приложения на устройствах типоразмера iPhone SE
    var isiPhoneSE: Bool {
        let iPhoneSEs: [DeviceModel] = [.iPhoneSE, .iPhoneSE2, .iPhoneSE3]
        return iPhoneSEs.contains(type)
    }
}
