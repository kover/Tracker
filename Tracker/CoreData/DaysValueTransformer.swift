//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Konstantin Penzin on 19.11.2023.
//

import Foundation

@objc(DaysValueTransformer)
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [TrackerSchedule] else {
            return nil
        }
        
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else {
            return nil
        }
        
        return try? JSONDecoder().decode([TrackerSchedule].self, from: data as Data)
    }
}
extension DaysValueTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))

    public static func register() {
        let transformer = DaysValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
