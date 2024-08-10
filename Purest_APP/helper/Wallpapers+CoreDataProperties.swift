//
//  Wallpapers+CoreDataProperties.swift
//  Note001
//
//  Created by Sophors Pheng on 7/28/24.
//
//

import Foundation
import CoreData


extension Wallpapers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wallpapers> {
        return NSFetchRequest<Wallpapers>(entityName: "Wallpapers")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var name: String?
    @NSManaged public var dateAdded: Date?

}

extension Wallpapers : Identifiable {

}
