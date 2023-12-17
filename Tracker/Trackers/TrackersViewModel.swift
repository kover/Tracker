//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Konstantin Penzin on 16.12.2023.
//

import Foundation

final class TrackersViewModel {
    
    var numberOfSections: Int {
        return visibleCategories.count
    }
    
    private var predicateString: String = ""
    var searchPredicate: String {
        set {
            predicateString = newValue
            setupCollectionData()
        }
        get {
            predicateString
        }
    }
    
    private var predicateDate: Date?
    var selectedDate: Date? {
        set {
            predicateDate = newValue
            setupCollectionData()
        }
        get {
            predicateDate
        }
    }
    
    private var qFilter: Filter?
    var quickFilter: Filter? {
        set {
            qFilter = newValue
            setupCollectionData()
        }
        get {
            qFilter
        }
    }

    private var categories: [TrackerCategory] = []
    private var trackers: [Tracker] = []
    
    @Observable
    private(set) var visibleCategories: [TrackerCategory] = []
    
    private(set) var completedTrackers: [TrackerRecord] = []
    
    private let categoryStore: TrackerCategoryStoreProtocol
    private let trackerStore: TrackerStoreProtocol
    private let recordStore: TrackerRecordStoreProtocol
    
    init(categoryStore: TrackerCategoryStoreProtocol, trackerStore: TrackerStoreProtocol, recordStore: TrackerRecordStoreProtocol) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        trackerStore.delegate = self
        self.completedTrackers = recordStore.getRecords()
        self.trackers = trackerStore.getTrackers()
        getCategories()
    }
    
    func numberOfItemsInSection(_ number: Int) -> Int {
        return visibleCategories[number].trackers.count
    }
    
    func item(at index: Int, in section: Int) -> Tracker {
        return visibleCategories[section].trackers[index]
    }
    
    func titleForSection(_ section: Int) -> String {
        return visibleCategories[section].title
    }
    
    func category(at section: Int) -> TrackerCategory {
        return visibleCategories[section]
    }
    
    func categoryFor(tracker: Tracker) -> TrackerCategory? {
        return categories.first { category in
            category.trackers.contains { $0.id == tracker.id }
        }
    }
        
    func trackersFor(date: Date) {
        
    }
}
// MARK: - Private routines
private extension TrackersViewModel {
    func getCategories() {
        self.categories = categoryStore.getCategories()
    }
    
    func setupCollectionData() {
        let pinnedTrackers: [Tracker] = categories.reduce([]) { accumulator, category in
            let pinned = category.trackers.filter({ $0.pinned })
            return accumulator + pinned
        }
        
        var filteredCategories: [TrackerCategory] = categories.compactMap({ category in
            guard category.trackers.count > 0
            else {
                return nil
            }
            
            let selectDay = Calendar.current.component(.weekday, from: predicateDate ?? Date())
            let categoryTrackers = category.trackers.filter { tracker in
                !tracker.pinned
            }.filter { tracker in
                tracker.schedule.contains { $0.numberOfDay == selectDay }
            }.filter { predicateString == "" ? true : $0.name.lowercased().contains(predicateString) }
                .filter { tracker in
                    switch (quickFilter) {
                    case .completedTrackers:
                        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: predicateDate ?? Date())) else {
                            return true
                        }
                        return completedTrackers.contains { $0.tracker.id == tracker.id && $0.date == date }
                    case .uncompletedTrackers:
                        let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: predicateDate ?? Date()))
                        return !completedTrackers.contains { $0.tracker.id == tracker.id && $0.date == date }
                    default:
                        return true
                    }
                }
            
            if categoryTrackers.count == 0 {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: categoryTrackers)
        })
        
        if pinnedTrackers.count > 0 {
            filteredCategories.insert(TrackerCategory(title: NSLocalizedString("trackers.pinnedCategory.title", comment: "Title for the pinned trackers section"), trackers: pinnedTrackers), at: 0)
        }
        
        visibleCategories = filteredCategories
    }
}

// MARK: - Trackers management
extension TrackersViewModel {
    func addTracker(_ tracker: Tracker, into category: TrackerCategory) {
        guard let categoryEntity = categoryStore.entityFor(category: category) else {
            return
        }
        trackerStore.addTracker(tracker, for: categoryEntity)
    }
    
    func updateTracker(_ tracker: Tracker, for category: TrackerCategory) {
        guard let categoryEntity = categoryStore.entityFor(category: category) else {
            return
        }
        trackerStore.updateTracker(tracker, for: categoryEntity)
    }
    
    func removeTracker(_ tracker: Tracker) {
        trackerStore.removeTracker(tracker)
    }

}

// MARK: - Tracker record management
extension TrackersViewModel {
    func updateRecordFor(tracker: Tracker, at date: Date, withCompletion isCompleted: Bool) {
        guard
            let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date)),
            let trackerEntity = trackerStore.getEntityFor(tracker: tracker)
        else {
            return
        }
        if isCompleted {
            recordStore.check(tracker: trackerEntity, for: date)
        } else {
            recordStore.uncheck(tracker: trackerEntity, for: date)
        }
        
        completedTrackers = recordStore.getRecords()
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackersViewModel: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        getCategories()
        completedTrackers = recordStore.getRecords()
        setupCollectionData()
    }
}


