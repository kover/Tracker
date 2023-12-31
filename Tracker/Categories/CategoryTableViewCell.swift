//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.11.2023.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    static let categoryTableViewCellIdentifier = "categoryTableViewCell"

    // MARK: - Layout items
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black")
        
        return label
    }()

    private lazy var checkImageView: UIImageView = {
        let image = UIImage(systemName: "checkmark")
        
        let imageview = UIImageView(image: image)
        
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.isHidden = true
        
        return imageview
    }()
    
    //MARK: - Cell configuration
    func setupCell(text: String, isSelected: Bool) {
        nameLabel.text = text
        
        contentView.backgroundColor = UIColor(named: "Background")
        
        checkImageView.isHidden = !isSelected
        
        setupSubviews()
        setupLayout()
    }
}
// MARK: - Layout configuration
private extension CategoryTableViewCell {
    func setupSubviews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(checkImageView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 65),
            
            checkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
