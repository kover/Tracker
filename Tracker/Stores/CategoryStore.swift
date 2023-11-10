//
//  CategoryStore.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.11.2023.
//

import Foundation

final class CategoryStore {
    static let shared = CategoryStore()
    
    private var categories: [TrackerCategory] = [TrackerCategory(title: "Default", trackers: [])]
    
    func getCategories() -> [TrackerCategory] {
        return categories
    }
    
    func addCategory(category: TrackerCategory) {
        categories.append(category)
    }
}
