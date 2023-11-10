//
//  EmojiTableViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 10.11.2023.
//

import UIKit

protocol EmojiTableViewCellDelegate: AnyObject {
    func updateEmoji(with emoji: String?)
}

final class EmojiTableViewCell: UITableViewCell {
    
    static let emojiTableViewCellIdentifier = "emojiTableViewCell"
    
    var delegate: EmojiTableViewCellDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Emoji"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "Black")
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSize(width: 52, height: 52)
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.isMultipleTouchEnabled = false
        collectionView.allowsMultipleSelection = false
        
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.emociCollectionViewCellIdentifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private let emoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                         "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                         "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    //MARK: - Cell configuration
    func setupCell() {
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(emojiCollectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            emojiCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

    }
}

// MARK: - UICollectionViewDataSource
extension EmojiTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoji.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.emociCollectionViewCellIdentifier, for: indexPath) as? EmojiCollectionViewCell
        guard let cell = cell else {
            return UICollectionViewCell()
        }
        
        cell.setupCell(emoji: emoji[indexPath.row])
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension EmojiTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(named: "LightGray")
        
        delegate?.updateEmoji(with: emoji[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
}

