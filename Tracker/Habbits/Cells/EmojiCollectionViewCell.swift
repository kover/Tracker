//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 10.11.2023.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    static let emociCollectionViewCellIdentifier = "emojiCollectionViewCell"

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.frame = bounds

        return label
    }()
    
    //MARK: - Cell configuration
    func setupCell(emoji: String) {
        emojiLabel.text = emoji
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7)
        ])
    }
}

