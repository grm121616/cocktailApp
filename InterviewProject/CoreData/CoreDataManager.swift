//
//  FashionFirstRow.swift
//  interviewProject
//
//  Created by Ruoming Gao on 9/7/19.
//  Copyright © 2019 Ruoming Gao. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
   
    var storeType: String!
    
    static let instance = CoreDataManager()
    
    private init(){}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "CocktailModel")
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = storeType
        persistentContainer.loadPersistentStores(completionHandler: { (_, _) in
        })
        return persistentContainer
    }()
    
    func getPersistentContainer(storyType: String)-> NSPersistentContainer {
        self.storeType = storyType
        return persistentContainer
    }
    
    func getContext(storeType: String = NSSQLiteStoreType) -> NSManagedObjectContext {
        let context = getPersistentContainer(storyType: storeType).viewContext
        return context
    }
    
    func createObject<T: NSManagedObject>(entity: T.Type, storeType: String = NSSQLiteStoreType) throws -> T {
        let context = getContext()
        let entityName = String(describing: entity)
        guard let description = NSEntityDescription.entity(forEntityName: entityName, in: context) else { throw error.invalidEntityType }
        let object = T(entity: description, insertInto: context)
        return object
    }
    
    func fetchAll<T: NSManagedObject>(entity: T.Type, storeType: String = NSSQLiteStoreType) throws -> [T] {
        let context = getContext()
        let entityName = String(describing: entity)
        let entity = NSFetchRequest<T>(entityName: entityName)
        let fetchObject = try context.fetch(entity)
        return fetchObject
    }
    
    func save() throws {
        let context = getContext()
        guard context.hasChanges else { return }
        try context.save()
    }
    
    func delete<T: NSManagedObject>(entity: T, storeType: String = NSSQLiteStoreType) {
        let context = getContext()
        context.delete(entity)
    }
    
    enum error: Error {
        case invalidEntityType
    }
}

