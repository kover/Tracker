//
//  CategoryStore.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.11.2023.
//

import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    func getCategories() -> [TrackerCategory]
    func addCategory(_ category: TrackerCategory)
}

final class TrackerCategoryStore: TrackerCategoryStoreProtocol {
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    private var categories: [TrackerCategory] = [TrackerCategory(title: "Default", trackers: [])]
    
    func getCategories() -> [TrackerCategory] {
        return categories
    }
    
    func addCategory(_ category: TrackerCategory) {
        categories.append(category)
    }
}
