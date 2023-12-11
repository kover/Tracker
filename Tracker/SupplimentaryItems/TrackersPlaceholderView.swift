//
//  TrackersPlaceholderView.swift
//  Tracker
//
//  Created by Konstantin Penzin on 15.09.2023.
//

import UIKit

class TrackersPlaceholderView: UIView {
    
    private var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Placeholder"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "TrackersPlaceholder"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
    }
    
    convenience init(placeholderText: String, frame: CGRect) {
        self.init(frame: frame)
        self.label.text = placeholderText
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
extension TrackersPlaceholderView {
    func updateText(_ text: String) {
        label.text = text
    }
    
    func updateImage(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        imageView.image = image
    }
}
