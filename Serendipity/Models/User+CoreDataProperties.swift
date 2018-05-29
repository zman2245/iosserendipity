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

    @NSManaged public var bio: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var creations: Memory?
    @NSManaged public var memories: NSSet?

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
