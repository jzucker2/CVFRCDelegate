//
//  Sample+CoreDataProperties.swift
//  CVFRCDelegate
//
//  Created by Jordan Zucker on 1/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Sample {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sample> {
        return NSFetchRequest<Sample>(entityName: "Sample");
    }

    @NSManaged public var name: String?
    @NSManaged public var uuid: String?
    @NSManaged public var creationDate: NSDate?

}
