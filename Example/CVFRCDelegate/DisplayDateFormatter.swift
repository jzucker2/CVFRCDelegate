//
//  DisplayDateFormatter.swift
//  CVFRCDelegate
//
//  Created by Jordan Zucker on 1/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class DisplayDateFormatter: DateFormatter {
    
    static let sharedFormatter = DisplayDateFormatter()
    
    override init() {
        super.init()
        timeStyle = .short
        dateStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func format(date: NSDate?) -> String? {
        guard let actualDate = date as? Date else {
            return nil
        }
        return string(from: actualDate)
    }
    
}
