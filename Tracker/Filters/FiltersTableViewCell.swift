//
//  FiltersTableViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 17.12.2023.
//

import UIKit

final class FiltersTableViewCell: UITableViewCell {
    
    static let filtersTableViewCellIdentifier = "filtersTableViewCell"
    
    //MARK: - Layout items
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
    
    //MARK: - Cell confituration
    func setupCell(name: String, checkMark: Bool) {
        nameLabel.text = name
        checkImageView.isHidden = !checkMark
        
        contentView.backgroundColor = UIColor(named: "Background")
        
        setupSubviews()
        setupLayout()
    }
}

//MARK: - Private routines
private extension FiltersTableViewCell {
    func setupSubviews() {
        [nameLabel, checkImageView].forEach { contentView.addSubview($0) }
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
