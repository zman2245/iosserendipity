//
//  Memory+CoreDataProperties.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/29/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension Memory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memory> {
        return NSFetchRequest<Memory>(entityName: "Memory")
    }

    @NSManaged public var id: Int64
    @NSManaged public var artworkLink: String?
    @NSManaged public var bgColor: Int32
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var imageLink: String?
    @NSManaged public var message: String?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var creator: User?
    @NSManaged public var currentHotspot: Hotspot?
    @NSManaged public var originalHotspot: Hotspot?
    @NSManaged public var owner: User?

}
