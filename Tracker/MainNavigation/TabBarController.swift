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
        view.backgroundColor = UIColor(named: "White")
        tabBar.layer.borderColor = UIColor(named: "Black")?.cgColor
        tabBar.layer.borderWidth = 0.2
        
        let trackerStore = TrackerStore()
        let trackerCategoryStore = TrackerCategoryStore()
        
        let trackersViewController = TrackersViewController(trackerStore: trackerStore, trackerCategoryStore: trackerCategoryStore)
        let statisticsViewController = StatisticsViewController()
        
        trackersViewController.navigationItem.title = "Трекеры"
        
        let trackersNavigation = UINavigationController()
        trackersNavigation.navigationBar.prefersLargeTitles = true
        trackersNavigation.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "Trackers"), selectedImage: nil)
        trackersNavigation.viewControllers = [trackersViewController]
        
        statisticsViewController.navigationItem.title = "Статистика"
        
        let statisticsNavigation = UINavigationController()
        statisticsNavigation.navigationBar.prefersLargeTitles = true
        statisticsNavigation.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "Statistics"), selectedImage: nil)
        statisticsNavigation.viewControllers = [statisticsViewController]
        
        self.viewControllers = [trackersNavigation, statisticsNavigation]
    }
    
}
