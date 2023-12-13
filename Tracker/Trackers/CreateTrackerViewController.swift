//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 15.09.2023.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    weak var delegate: CreateHabbitViewControllerDelegate?
    
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    
    init(trackerCategoryStore: TrackerCategoryStoreProtocol) {
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout items
    private lazy var createHabitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(NSLocalizedString("createHabbit.button", comment: "The title for the create habbit button"), for: .normal)
        button.addTarget(self, action: #selector(createHabbit), for: .touchUpInside)
        button.backgroundColor = UIColor(named: "Black")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private lazy var createEventButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(NSLocalizedString("createIrregularEvent.button", comment: "The title for the create irregular event button"), for: .normal)
        button.addTarget(self, action: #selector(createIrregularEvent), for: .touchUpInside)
        button.backgroundColor = UIColor(named: "Black")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        return button
    }()

    // MARK: - Lifecycle hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("createTrackerView.title", comment: "The title for the create tracker view")
        
        view.backgroundColor = UIColor.white
        
        setupSubviews()
        setupLayout()
    }

    @objc func createHabbit() {
        let createHabbitViewController = CreateHabbitViewController(trackerCategoryStore: trackerCategoryStore)
        createHabbitViewController.title = NSLocalizedString("newHabbitView.title", comment: "The title for the new habbit view")
        createHabbitViewController.delegate = delegate
        createHabbitViewController.cells = [
            0: ["textField"],
            1: ["category","shedule"],
            2: ["emoji"],
            3: ["colors"]
        ]

        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [createHabbitViewController]

        present(navigationController, animated: true)
    }
    
    @objc func createIrregularEvent() {
        let createHabbitViewController = CreateHabbitViewController(trackerCategoryStore: trackerCategoryStore)
        createHabbitViewController.title = NSLocalizedString("newEventView.title", comment: "The title for the new irregular event view")
        createHabbitViewController.delegate = delegate
        createHabbitViewController.cells = [
            0: ["textField"],
            1: ["category"],
            2: ["emoji"],
            3: ["colors"]
        ]

        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [createHabbitViewController]

        present(navigationController, animated: true)
    }
}
// MARK: - Layout configuration
private extension CreateTrackerViewController {
    func setupSubviews() {
        view.addSubview(createEventButton)
        view.addSubview(createHabitButton)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            createHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createHabitButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -38),
            createHabitButton.heightAnchor.constraint(equalToConstant: 60),
            
            createEventButton.leadingAnchor.constraint(equalTo: createHabitButton.leadingAnchor),
            createEventButton.trailingAnchor.constraint(equalTo: createHabitButton.trailingAnchor),
            createEventButton.topAnchor.constraint(equalTo: createHabitButton.bottomAnchor, constant: 16),
            createEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])

    }
}
