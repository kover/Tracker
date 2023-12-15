//
//  TrackerStore.swift
//  Tracker
//
//  Created by Konstantin Penzin on 12.11.2023.
//

import CoreData
import UIKit

protocol TrackerStoreProtocol: AnyObject {
    var delegate: TrackerStoreDelegate? { get set }
    var numberOfSections: Int { get }
    var selectedDate: Date? { get set }
    var searchPredicate: String? { get set }
    func addTracker(_ tracker: Tracker, for category: TrackerCategoryCoreData)
    func updateTracker(_ tracker: Tracker, for category: TrackerCategoryCoreData)
    func removeTracker(_ tracker: Tracker)
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    func titleForSection(at indexPath: IndexPath) -> String
    func getEntityFor(tracker: Tracker) -> TrackerCoreData?
}

struct TrackerStoreUpdate {
    let insertedIndexes: [IndexPath]
    let updatedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

enum TrackerError: Error {
    case failedToConvertTracker
}

final class TrackerStore: NSObject {
    
    private var context: NSManagedObjectContext
    private var predicateDate: Date?
    private var predicateString: String?
    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: [IndexPath]?
    private var updatedIndexes: [IndexPath]?
    private var deletedIndexes: [IndexPath]?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
    
    func updateTrackerEntity(_ entity: TrackerCoreData, with tracker: Tracker, for category: TrackerCategoryCoreData) {
        entity.id = tracker.id
        entity.color = tracker.color
        entity.emoji = tracker.emoji
        entity.name = tracker.name
        entity.schedule = NSArray(array: tracker.schedule)
        entity.scheduleString = tracker.schedule.compactMap { String($0.numberOfDay) }.joined(separator: ",")
        entity.category = category
        saveContext()
    }
}
// MARK: Private routines
private extension TrackerStore {
    func convertFetchedTrackers(_ data: [TrackerCoreData]) -> [Tracker] {
        var trackers: [Tracker] = []
        
        data.forEach {
            guard let id = $0.id,
                  let name = $0.name,
                  let color = $0.color as? UIColor,
                  let emoji = $0.emoji,
                  let schedule = $0.schedule as? [TrackerSchedule]
            else {
                return
            }
            
            trackers.append(Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule))
        }
        return trackers
    }
    
    func convertFetchedCategory(_ data: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = data.title,
              let trackers = data.trackers?.allObjects as? [TrackerCoreData] else {
            throw TrackerCategoryError.failedToConvertCategory
        }
        return TrackerCategory(title: title, trackers: convertFetchedTrackers(trackers))
    }

}
// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    
    var selectedDate: Date? {
        set {
            predicateDate = newValue
            let dayNumber = Calendar.current.component(.weekday, from: predicateDate ?? Date())
            if let predicateString = predicateString, predicateString != "" {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "scheduleString CONTAINS %@ AND name CONTAINS [c] %@", String(dayNumber), predicateString)
            } else {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "scheduleString CONTAINS %@", String(dayNumber))
            }
            try? fetchedResultsController.performFetch()
        }
        get {
            predicateDate
        }
    }
    
    
    var searchPredicate: String? {
        set {
            predicateString = newValue
            
            let dayNumber = Calendar.current.component(.weekday, from: predicateDate ?? Date())
            
            if let predicateString = predicateString, predicateString != "" {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "scheduleString CONTAINS %@ AND name CONTAINS [c] %@", String(dayNumber), predicateString)
            } else {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "scheduleString CONTAINS %@", String(dayNumber))
            }
            try? fetchedResultsController.performFetch()
            
        }
        get {
            predicateString
        }
    }

    func addTracker(_ tracker: Tracker, for category: TrackerCategoryCoreData) {
        let entity = TrackerCoreData(context: context)
        updateTrackerEntity(entity, with: tracker, for: category)
    }
    
    func updateTracker(_ tracker: Tracker, for category: TrackerCategoryCoreData) {
        guard let entity = fetchedResultsController.fetchedObjects?.first(where: { $0.id == tracker.id }) else {
            return
        }
        updateTrackerEntity(entity, with: tracker, for: category)
    }
    
    func removeTracker(_ tracker: Tracker) {
        guard let entity = fetchedResultsController.fetchedObjects?.first(where: { $0.id == tracker.id }) else {
            return
        }
        context.delete(entity)
        saveContext()
    }
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at: IndexPath) -> Tracker? {
        let tracker = fetchedResultsController.object(at: at)
        
        guard let id = tracker.id,
              let name = tracker.name,
              let color = tracker.color as? UIColor,
              let emoji = tracker.emoji,
              let schedule = tracker.schedule as? [TrackerSchedule]
        else {
            return nil
        }
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    func titleForSection(at indexPath: IndexPath) -> String {
        let tracker = fetchedResultsController.object(at: indexPath)
        
        return tracker.category?.title ?? ""
    }
    
    func getEntityFor(tracker: Tracker) -> TrackerCoreData? {
        return fetchedResultsController.fetchedObjects?.first(where: { $0.id == tracker.id })
    }
}
// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        updatedIndexes = []
        deletedIndexes = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                updatedIndexes: updatedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        updatedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.append(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.append(indexPath)
            }
        case .update:
            if let indexPath = newIndexPath {
                updatedIndexes?.append(indexPath)
            }
        default:
            break
        }
    }
}
