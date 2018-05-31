//
//  User+CoreDataProperties.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/29/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var bio: String?
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var creations: Memory?
    @NSManaged public var memories: NSSet?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var updatedAt: NSDate?
}

// MARK: Generated accessors for memories
extension User {

    @objc(addMemoriesObject:)
    @NSManaged public func addToMemories(_ value: Memory)

    @objc(removeMemoriesObject:)
    @NSManaged public func removeFromMemories(_ value: Memory)

    @objc(addMemories:)
    @NSManaged public func addToMemories(_ values: NSSet)

    @objc(removeMemories:)
    @NSManaged public func removeFromMemories(_ values: NSSet)

}
