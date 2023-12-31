//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.12.2023.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private var pages: [UIViewController] = []
    
    // MARK: - Layout items
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(named: "Black")
        pageControl.pageIndicatorTintColor = UIColor(named: "Background")
        
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
    }
}

// MARK: - Private routines
private extension OnboardingViewController {
    func configureController() {
        dataSource = self
        delegate = self
        
        pages.append(OnboardingPage(
            image: UIImage(named: "OnboardingOne"),
            textLabel: NSLocalizedString("firstOnboardingMessage", comment: "Message on the first onboarding screen")
        ))
        
        if let first = pages.first {
            setViewControllers(
                [first],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
        setupSubviews()
        setupLayout()
    }
    
    func setupSubviews() {
        view.addSubview(pageControl)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if pages.count < 2 {
            pages.append(OnboardingPage(
                image: UIImage(named: "OnboardingTwo"),
                textLabel: NSLocalizedString("secondOnboardingMessage", comment: "Message on the second onboarding screen")
            ))
        }
        
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return nil }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
