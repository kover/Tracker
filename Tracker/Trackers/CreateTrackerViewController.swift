//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 15.09.2023.
//

import UIKit

class CreateTrackerViewController: UIViewController {

    private lazy var createHabitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Привычка", for: .normal)
        button.addTarget(self, action: #selector(createHabbit), for: .touchUpInside)
        button.backgroundColor = UIColor(named: "Black")
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    private lazy var createEventButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Нерегулярное событие", for: .normal)
        button.addTarget(self, action: #selector(createIrregularEvent), for: .touchUpInside)
        button.backgroundColor = UIColor(named: "Black")
        button.layer.cornerRadius = 16
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание трекера"
        
        configureViews()
    }

    @objc func createHabbit() {
        let createHabbitViewController = CreateHabbitViewController()
        createHabbitViewController.title = "Новая привычка"
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [createHabbitViewController]

        present(navigationController, animated: true)
    }
    
    @objc func createIrregularEvent() {
    }
    
    private func configureViews() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(createEventButton)
        view.addSubview(createHabitButton)
        
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
