//
//  UIColorValueTransformer.swift
//  Tracker
//
//  Created by Konstantin Penzin on 30.11.2023.
//

import UIKit

@objc(UIColorValueTransformer)
final class UIColorValueTransformer: ValueTransformer {
    override public class func transformedValueClass() -> AnyClass {
        return UIColor.self
    }

    override public class func allowsReverseTransformation() -> Bool {
        return true
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
}
extension UIColorValueTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: UIColorValueTransformer.self))

    public static func register() {
        let transformer = UIColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
