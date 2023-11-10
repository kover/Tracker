//
//  TrackersCollectionReusableView.swift
//  Tracker
//
//  Created by Konstantin Penzin on 12.11.2023.
//

import UIKit

class TrackersCollectionReusableView: UICollectionReusableView {
    static let trackerCollectionReusableViewIdentifier = "TrackerCollectionReusableView"

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "Black")
        label.frame = bounds
        
        return label
    }()
    
    //MARK: - Cell configuration
    func setupCell(title: String) {
        titleLabel.text = title
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -28),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}

