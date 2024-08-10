//
//  Folder+CoreDataProperties.swift
//  Note001
//
//  Created by Sophors Pheng on 7/20/24.
//
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var folderID: String?
    @NSManaged public var folderName: String?
    @NSManaged public var notes: Notes?

}

extension Folder : Identifiable {

}
