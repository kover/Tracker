//
//  HabbitSetupTableViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 10.11.2023.
//

import UIKit

class HabbitSetupTableViewCell: UITableViewCell {
    
    static let habbitSetupTableViewCellIdentifier = "habbitSetupTableViewCellIdentifier"
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 2
        
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(named: "Black")
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(named: "Gray")
        
        return label
    }()
    
    private lazy var accessoryImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = image
        imageView.tintColor = UIColor(named: "Gray")
        
        return imageView
    }()
    
    //MARK: - Cell configuration
    func setupCell(text: String, description: String?) {
        contentView.backgroundColor = UIColor(named: "Background")
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        contentView.addSubview(accessoryImageView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 46),
            
            accessoryImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 7),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 12),
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        titleLabel.text = text
        
        if let description = description {
            descriptionLabel.text = description
        }
    }
}
