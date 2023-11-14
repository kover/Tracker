//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 10.11.2023.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let colorCollectionViewCellIdentifier = "colorCollectionViewCell"
    
    // MARK: - Layout items
    private lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        
        return view
    }()
    
    //MARK: - Cell configuration
    func setupCell(color: UIColor) {
        colorView.backgroundColor = color

        setupSubviews()
        setupLayout()
    }
}

// MARK: - Layout configuration
private extension ColorCollectionViewCell {
    func setupSubviews() {
        contentView.addSubview(colorView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
}
