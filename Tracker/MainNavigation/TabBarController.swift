//
//  TabBarController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 14.09.2023.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabs()
    }
    
    private func configureTabs() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let trackersViewController = storyboard.instantiateViewController(withIdentifier: "TrackersViewController")
        let statisticsViewController = storyboard.instantiateViewController(withIdentifier: "StatisticsViewController")
        
        guard
            let trackersViewController = trackersViewController as? TrackersViewController,
            let statisticsViewController = statisticsViewController as? StatisticsViewController
        else {
            return
        }
        
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
