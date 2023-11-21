//
//  TrackerStore.swift
//  Tracker
//
//  Created by Konstantin Penzin on 12.11.2023.
//

import Foundation
import CoreData

protocol TrackerStoreProtocol {
    func addTracker(_ tracker: Tracker)
}

final class TrackerStore: TrackerStoreProtocol {
    
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    func addTracker(_ tracker: Tracker) {
        let trackerEntity = TrackerCoreData(context: context)
        updateTrackerEntity(trackerEntity, with: tracker)
    }
    
    func updateTrackerEntity(_ entity: TrackerCoreData, with tracker: Tracker) {
        entity.color = tracker.color
        entity.emoji = tracker.emoji
        entity.name = tracker.name
        entity.schedule = tracker.schedule as NSObject
    }
}
