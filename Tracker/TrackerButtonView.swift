//
//  TrackerButtonView.swift
//  Tracker
//
//  Created by Konstantin Penzin on 21.09.2023.
//

import UIKit

class TrackerButtonView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let cornerRadius = max(frame.width, frame.height) / 2.0
        
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
