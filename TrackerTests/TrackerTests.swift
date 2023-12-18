//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Konstantin Penzin on 29.08.2023.
//

import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackerTests: XCTestCase {

    class MockAnalytics: AnalyticsServiceProtocol {
        func report(event: AnalyticsEvents, params: [AnyHashable : Any]) {
            return
        }
    }
    
    func testTrackerViewControllerLight() {
        let trackerStore = TrackerStore()
        let trackerCategoryStore = TrackerCategoryStore()
        let trackerRecordStore = TrackerRecordStore()
        
        let trackersViewModel = TrackersViewModel(
            categoryStore: trackerCategoryStore,
            trackerStore: trackerStore,
            recordStore: trackerRecordStore
        )
        
        let trackersViewController = TrackersViewController(
            trackerCategoryStore: trackerCategoryStore,
            viewModel: trackersViewModel,
            analyticsService: MockAnalytics()
        )
        assertSnapshot(matching: trackersViewController.view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackerViewControllerDark() {
        let trackerStore = TrackerStore()
        let trackerCategoryStore = TrackerCategoryStore()
        let trackerRecordStore = TrackerRecordStore()
        
        let trackersViewModel = TrackersViewModel(
            categoryStore: trackerCategoryStore,
            trackerStore: trackerStore,
            recordStore: trackerRecordStore
        )
        
        let trackersViewController = TrackersViewController(
            trackerCategoryStore: trackerCategoryStore,
            viewModel: trackersViewModel,
            analyticsService: MockAnalytics()
        )
        assertSnapshot(matching: trackersViewController.view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }


}
