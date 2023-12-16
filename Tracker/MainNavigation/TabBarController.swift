//
//  TabBarController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 14.09.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabs()
    }
    
    private func configureTabs() {
        view.backgroundColor = .systemBackground
        tabBar.layer.borderColor = UIColor(named: "Black")?.cgColor
        tabBar.layer.borderWidth = 0.2
        
        let trackerStore = TrackerStore()
        let trackerCategoryStore = TrackerCategoryStore()
        let trackerRecordStore = TrackerRecordStore()
        let analyticsService = AnalyticsService()
        
        let trackersViewModel = TrackersViewModel(
            categoryStore: trackerCategoryStore,
            trackerStore: trackerStore,
            recordStore: trackerRecordStore
        )
        
        let trackersViewController = TrackersViewController(
            trackerCategoryStore: trackerCategoryStore,
            viewModel: trackersViewModel,
            analyticsService: analyticsService
        )
        let statisticsViewController = StatisticsViewController(recordStore: trackerRecordStore)
        
        trackersViewController.navigationItem.title = NSLocalizedString("trackers.title", comment: "The title for the trackers page")
        
        let trackersNavigation = UINavigationController()
        trackersNavigation.navigationBar.prefersLargeTitles = true
        trackersNavigation.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers.title", comment: "The title for the trackers page"), image: UIImage(named: "Trackers"), selectedImage: nil)
        trackersNavigation.viewControllers = [trackersViewController]
        
        statisticsViewController.navigationItem.title = NSLocalizedString("statistics.title", comment: "The title for the statistics page")
        
        let statisticsNavigation = UINavigationController()
        statisticsNavigation.navigationBar.prefersLargeTitles = true
        statisticsNavigation.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics.title", comment: "The title for the statistics page"), image: UIImage(named: "Statistics"), selectedImage: nil)
        statisticsNavigation.viewControllers = [statisticsViewController]
        
        self.viewControllers = [trackersNavigation, statisticsNavigation]
    }
    
}
