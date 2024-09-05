//
//  TaskInteractor.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import CoreData
import Foundation

class TaskInteractor: TaskInteractorProtocol {
    private let context = PersistenceController.shared.viewContext
    private let queue = DispatchQueue(label: "com.todoApp.taskQueue", attributes: .concurrent)
    
    func fetchTasks(completion: @escaping ([TaskEntity]) -> Void) {
        queue.async {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            do {
                let tasks = try self.context.fetch(fetchRequest)
                let taskEntities = tasks.map { TaskEntity(id: $0.id!, title: $0.title!, details: $0.details!, createdAt: $0.createdAt!, isCompleted: $0.isCompleted) }
                
                DispatchQueue.main.async {
                    completion(taskEntities)
                }
            } catch {
                print("Failed to fetch tasks: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    func fetchTasksFromAPI(completion: @escaping ([TaskEntity]) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }
        
        queue.async {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                        let tasks = decodedResponse.todos.map { apiTask -> TaskEntity in
                            let newTask = TaskEntity(id: UUID(), title: apiTask.todo, details: "", createdAt: Date(), isCompleted: apiTask.completed)
                            return newTask
                        }
                        self.saveTasksToCoreData(tasks: tasks)
                        
                        DispatchQueue.main.async {
                            completion(tasks)
                        }
                    } catch {
                        print("Failed to decode tasks: \(error)")
                        DispatchQueue.main.async {
                            completion([])
                        }
                    }
                } else if let error = error {
                    print("Failed to fetch tasks: \(error)")
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            }.resume()
        }
    }
    
    private func saveTasksToCoreData(tasks: [TaskEntity]) {
        queue.async(flags: .barrier) {
            tasks.forEach { taskEntity in
                let newTask = Task(context: self.context)
                newTask.id = taskEntity.id
                newTask.title = taskEntity.title
                newTask.details = taskEntity.details
                newTask.createdAt = taskEntity.createdAt
                newTask.isCompleted = taskEntity.isCompleted
            }
            self.saveContext()
        }
    }

    func addTask(title: String, details: String, completion: @escaping () -> Void) {
        queue.async(flags: .barrier) {
            let newTask = Task(context: self.context)
            newTask.id = UUID()
            newTask.title = title
            newTask.details = details
            newTask.createdAt = Date()
            newTask.isCompleted = false

            self.saveContext()

            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func updateTask(task: TaskEntity, completion: @escaping () -> Void) {
        queue.async(flags: .barrier) {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                let tasks = try self.context.fetch(fetchRequest)
                if let taskToUpdate = tasks.first {
                    taskToUpdate.title = task.title
                    taskToUpdate.details = task.details
                    taskToUpdate.isCompleted = task.isCompleted
                    self.saveContext()
                }
            } catch {
                print("Failed to update task: \(error)")
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func deleteTask(task: TaskEntity, completion: @escaping () -> Void) {
        queue.async(flags: .barrier) {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                let tasks = try self.context.fetch(fetchRequest)
                if let taskToDelete = tasks.first {
                    self.context.delete(taskToDelete)
                    self.saveContext()
                }
            } catch {
                print("Failed to delete task: \(error)")
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
