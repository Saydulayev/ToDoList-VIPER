//
//  PersistenceController.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation
import CoreData


class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model") // Замените "YourModelName" на имя вашего .xcdatamodeld файла
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Замените это на реализацию обработки ошибок в вашем приложении
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
