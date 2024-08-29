//
//  UIColorToDataTransformer.swift
//  Tracker
//
//  Created by Сергей Кухарев on 22.08.2024.
//

import Foundation
import UIKit

final class UIColorToDataTransformer: ValueTransformer {
    // MARK: - Constants

    static let name = NSValueTransformerName(rawValue: String(describing: UIColorToDataTransformer.self))

    // MARK: - Public Methods

    override public static func allowsReverseTransformation() -> Bool {
        return true
    }

    public static func register() {
        let transformer = UIColorToDataTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }

    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }

        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data as Data)
            return color
        } catch {
            assertionFailure("Failed to transform `Data` to `UIColor`")
            return nil
        }
    }

    override public func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch {
            assertionFailure("Failed to transform `UIColor` to `Data`")
            return nil
        }
    }

    override public static func transformedValueClass() -> AnyClass {
        return UIColor.self
    }
}
