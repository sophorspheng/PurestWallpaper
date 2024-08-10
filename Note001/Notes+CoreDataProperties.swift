//
//  Notes+CoreDataProperties.swift
//  Note001
//
//  Created by Sophors Pheng on 7/20/24.
//
//

import Foundation
import CoreData


extension Notes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }

    @NSManaged public var noteID: String?
    @NSManaged public var titles: String?
    @NSManaged public var detail: String?
    @NSManaged public var folder: Folder?

}

extension Notes : Identifiable {

}
