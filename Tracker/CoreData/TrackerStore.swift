//
//  TrackerStore.swift
//  Tracker
//
//  Created by Konstantin Penzin on 12.11.2023.
//

import UIKit
import CoreData

protocol TrackerStoreProtocol: AnyObject {
    func addTracker(_ tracker: Tracker, for category: TrackerCategoryCoreData)
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    var delegate: TrackerStoreDelegate? { get set }
    func titleForSection(at indexPath: IndexPath) -> String
}

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

enum TrackerError: Error {
    case failedToConvertTracker
}

final class TrackerStore: NSObject {
    
    private var context: NSManagedObjectContext
    
    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
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
        
        print("tracker", context)
        
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
        entity.schedule = try? JSONEncoder().encode(tracker.schedule)
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
                  let scheduleRaw = $0.schedule,
                  let schedule = try? JSONDecoder().decode([TrackerSchedule].self, from: scheduleRaw)
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
    func addTracker(_ tracker: Tracker, for category: TrackerCategoryCoreData) {
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.color = tracker.color
        entity.emoji = tracker.emoji
        entity.name = tracker.name
        entity.schedule = try? JSONEncoder().encode(tracker.schedule)
        entity.category = category
        saveContext()
    }
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
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
              let scheduleRaw = tracker.schedule,
              let schedule = try? JSONDecoder().decode([TrackerSchedule].self, from: scheduleRaw)
        else {
            return nil
        }
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    func titleForSection(at indexPath: IndexPath) -> String {
        let tracker = fetchedResultsController.object(at: indexPath)
        
        return tracker.category?.title ?? ""
    }
}
// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                updatedIndexes: updatedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .update:
            if let indexPath = newIndexPath {
                updatedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }

}
