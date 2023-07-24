//
//  Image+CoreDataProperties.swift
//  interviewProject
//
//  Created by Ruoming Gao on 9/8/19.
//  Copyright © 2019 Ruoming Gao. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var imageurl: NSData?
    @NSManaged public var favorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var instruction: String?
    @NSManaged public var ingret: String?
    @NSManaged public var measurements: String?
    @NSManaged public var isCustom: Bool
}
