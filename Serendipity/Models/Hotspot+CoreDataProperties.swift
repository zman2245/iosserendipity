//
//  Hotspot+CoreDataProperties.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/29/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension Hotspot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hotspot> {
        return NSFetchRequest<Hotspot>(entityName: "Hotspot")
    }

    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var radiusFeet: Int32
    @NSManaged public var memories: NSSet?

}

// MARK: Generated accessors for memories
extension Hotspot {

    @objc(addMemoriesObject:)
    @NSManaged public func addToMemories(_ value: Memory)

    @objc(removeMemoriesObject:)
    @NSManaged public func removeFromMemories(_ value: Memory)

    @objc(addMemories:)
    @NSManaged public func addToMemories(_ values: NSSet)

    @objc(removeMemories:)
    @NSManaged public func removeFromMemories(_ values: NSSet)

}
