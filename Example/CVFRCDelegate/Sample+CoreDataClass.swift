//
//  Sample+CoreDataClass.swift
//  CVFRCDelegate
//
//  Created by Jordan Zucker on 1/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(Sample)
public class Sample: NSManagedObject {
    
    static func saveObject(title: String) {
        DataController.sharedController.persistentContainer.performBackgroundTask({ (context) in
            let createdSample = Sample(context: context)
            createdSample.name = title
            do {
                try context.save()
                print(#function)
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
        creationDate = NSDate()
    }

}
