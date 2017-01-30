//
//  SampleCollectionViewCell.swift
//  CVFRCDelegate
//
//  Created by Jordan Zucker on 1/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import CoreData

class SampleCollectionViewCell: UICollectionViewCell {
    
    let sampleLabel: UILabel
    
    override init(frame: CGRect) {
        self.sampleLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        sampleLabel.adjustsFontSizeToFitWidth = true
        sampleLabel.numberOfLines = 2
        contentView.addSubview(sampleLabel)
        sampleLabel.forceAutoLayout()
        sampleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0).isActive = true
        sampleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0).isActive = true
        sampleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        sampleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sampleLabel.text = nil
    }
    
    
    func update(with text: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.sampleLabel.text = text
            self?.setNeedsLayout()
        }
    }
    
}
