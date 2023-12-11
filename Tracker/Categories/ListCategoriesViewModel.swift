//
//  ListCategoriesViewModel.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.12.2023.
//

import Foundation

final class ListCategoriesViewModel {
    
    var numberOfRows: Int {
        return categories.count
    }
    
    var shouldHidePlaceholder: Bool {
        return categories.count > 0
    }
    
    var selectedCategory: TrackerCategory?
    
    @Observable
    private(set) var categories: [TrackerCategory] = []
    
    private let categoryStore: TrackerCategoryStoreProtocol
    
    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        categoryStore.delegate = self
        getCategories()
    }
    
    func createCategory(_ title: String) {
        categoryStore.addCategory(TrackerCategory(title: title, trackers: []))
    }
    
    func categoryAt(_ index: Int) -> TrackerCategory? {
        return categories[index]
    }
    
    func isSelected(category: TrackerCategory) -> Bool {
        return category.title == selectedCategory?.title
    }
    
}

// MARK: - Private routines
private extension ListCategoriesViewModel {
    func getCategories() {
        self.categories = categoryStore.getCategories()
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension ListCategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        getCategories()
    }
}
