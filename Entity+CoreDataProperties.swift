//
//  Entity+CoreDataProperties.swift
//  SampleForSwift
//
//  Created by INNOISDF700278 on 9/4/17.
//  Copyright © 2017 INNOISDF700278. All rights reserved.
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var categaryoption: String?
    @NSManaged public var comments: String?
    @NSManaged public var location: String?
    @NSManaged public var image: NSData?

}
