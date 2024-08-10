//
//  CoreDataManager.swift
//  Note001
//
//  Created by Sophors Pheng on 7/21/24.
//

import Foundation
import CoreData
class CoreDataManager{
    static let shared = CoreDataManager()
    private let container = NSPersistentContainer(name: "CoreData")
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    private init() {
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    func save() throws {
        do {
            try context.save()
        } catch {
            print(error)
            throw error
        }
    }
}
