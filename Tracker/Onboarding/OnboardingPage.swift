//
//  OnboardingPage.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.12.2023.
//

import UIKit

final class OnboardingPage: UIViewController {
    
    // MARK: - Layout items
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Отслеживайте только \n то, что хотите"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(named: "Black")
        label.textAlignment = .center
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "Black")
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.textColor = UIColor(named: "White")
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Initialization
    init(image: UIImage?, textLabel: String) {
        super.init(nibName: nil, bundle: nil)
        
        imageView.image = image
        label.text = textLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupLayout()
    }
}

private extension OnboardingPage {
    func setupSubviews() {
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(button)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc
    func buttonTap() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        UserDefaults.standard.set(true, forKey: "showOnboarding")
        window.rootViewController = TabBarController()
    }
}
