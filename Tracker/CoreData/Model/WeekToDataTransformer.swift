//
//  WeekToDataTransformer.swift
//  Tracker
//
//  Created by Сергей Кухарев on 22.08.2024.
//

import Foundation

final class WeekToDataTransformer: ValueTransformer {
    // MARK: - Constants

    static let name = NSValueTransformerName(rawValue: String(describing: WeekToDataTransformer.self))

    // MARK: - Public Methods

    override public static func allowsReverseTransformation() -> Bool {
        return true
    }

    public static func register() {
        let transformer = WeekToDataTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }

    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }

        do {
            return try JSONDecoder().decode(Week.self, from: data as Data)
        } catch {
            assertionFailure("Failed to transform `Data` to `Week`")
            return nil
        }
    }

    override public func transformedValue(_ value: Any?) -> Any? {
        guard let week = value as? Week else { return nil }

        do {
            return try JSONEncoder().encode(week)
        } catch {
            assertionFailure("Failed to transform `Week` to `Data`")
            return nil
        }
    }

    override public static func transformedValueClass() -> AnyClass {
        return NSData.self
    }
}
