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
    
    private let emoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                         "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                         "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private var selectedEmoji: String?
    
    // MARK: - Layout items
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
    
    //MARK: - Cell configuration
    func setupCell(selectedEmoji: String?) {
        selectionStyle = .none
        
        self.selectedEmoji = selectedEmoji
        
        setupSubviews()
        setupLayout()
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
        
        if let selectedEmoji = selectedEmoji,
           selectedEmoji == emoji[indexPath.row] {
            emojiCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            cell.backgroundColor = UIColor(named: "LightGray")
        }
        
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

// MARK: - Layout configuration
private extension EmojiTableViewCell {
    func setupSubviews() {
        contentView.backgroundColor = UIColor(named: "MainBackground")
        contentView.addSubview(titleLabel)
        contentView.addSubview(emojiCollectionView)
    }
    
    func setupLayout() {
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
