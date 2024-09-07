//
//  TaskInteractor.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation
import CoreData


class TaskInteractor: TaskInteractorProtocol {
    private let context = PersistenceController.shared.viewContext
    private let queue = DispatchQueue(label: "com.todoApp.taskQueue", attributes: .concurrent)
    
    // Fetch tasks from Core Data
    func fetchTasks(completion: @escaping ([TaskEntity]) -> Void) {
        queue.async {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            do {
                let tasks = try self.context.fetch(fetchRequest)
                let taskEntities = tasks.compactMap { task -> TaskEntity? in
                    guard let id = task.id, let title = task.title, let details = task.details, let createdAt = task.createdAt else {
                        return nil
                    }
                    return TaskEntity(
                        id: id,
                        title: title,
                        details: details,
                        createdAt: createdAt,
                        startTime: task.startTime,
                        endTime: task.endTime,
                        isCompleted: task.isCompleted
                    )
                }
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

    // Fetch tasks from API and save to Core Data
    func fetchTasksFromAPI(completion: @escaping ([TaskEntity]) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        queue.async {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Failed to fetch tasks: \(error)")
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    let tasks = decodedResponse.todos.map { apiTask -> TaskEntity in
                        TaskEntity(
                            id: UUID(),
                            title: apiTask.todo,
                            details: "",
                            createdAt: Date(),
                            startTime: nil,
                            endTime: nil,
                            isCompleted: apiTask.completed
                        )
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
            }.resume()
        }
    }
    
    // Save tasks to Core Data
    private func saveTasksToCoreData(tasks: [TaskEntity]) {
        queue.async(flags: .barrier) {
            tasks.forEach { taskEntity in
                // Check if task with the same title already exists to avoid duplicates
                let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "title == %@", taskEntity.title)
                
                do {
                    let existingTasks = try self.context.fetch(fetchRequest)
                    if existingTasks.isEmpty {
                        let newTask = Task(context: self.context)
                        newTask.id = taskEntity.id
                        newTask.title = taskEntity.title
                        newTask.details = taskEntity.details
                        newTask.createdAt = taskEntity.createdAt
                        newTask.startTime = taskEntity.startTime
                        newTask.endTime = taskEntity.endTime
                        newTask.isCompleted = taskEntity.isCompleted
                    }
                } catch {
                    print("Failed to check for existing task: \(error)")
                }
            }
            self.saveContext()
        }
    }

    // Add a new task
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        queue.async(flags: .barrier) {
            // Проверка на наличие задачи с таким же заголовком
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", title)
            
            do {
                let existingTasks = try self.context.fetch(fetchRequest)
                if existingTasks.isEmpty {
                    let newTask = Task(context: self.context)
                    newTask.id = UUID()
                    newTask.title = title
                    newTask.details = details
                    newTask.createdAt = Date()
                    newTask.startTime = startTime
                    newTask.endTime = endTime
                    newTask.isCompleted = false

                    self.saveContext()
                    
                    DispatchQueue.main.async {
                        onSuccess()
                    }
                } else {
                    DispatchQueue.main.async {
                        onFailure(nil)
                    }
                }
            } catch {
                print("Failed to add task: \(error)")
                DispatchQueue.main.async {
                    onFailure(error)
                }
            }
        }
    }
    
    // Update an existing task
    func updateTask(task: TaskEntity, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        queue.async(flags: .barrier) {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                let tasks = try self.context.fetch(fetchRequest)
                if let taskToUpdate = tasks.first {
                    // Проверка на наличие другой задачи с таким же заголовком
                    let titleCheckRequest: NSFetchRequest<Task> = Task.fetchRequest()
                    titleCheckRequest.predicate = NSPredicate(format: "title == %@ AND id != %@", task.title, task.id as CVarArg)
                    
                    let existingTasksWithTitle = try self.context.fetch(titleCheckRequest)
                    
                    if existingTasksWithTitle.isEmpty {
                        taskToUpdate.title = task.title
                        taskToUpdate.details = task.details
                        taskToUpdate.startTime = task.startTime
                        taskToUpdate.endTime = task.endTime
                        taskToUpdate.isCompleted = task.isCompleted
                        self.saveContext()
                        
                        DispatchQueue.main.async {
                            onSuccess()
                        }
                    } else {
                        DispatchQueue.main.async {
                            onFailure(nil)
                        }
                    }
                } else {
                    print("Task not found")
                    DispatchQueue.main.async {
                        onFailure(nil)
                    }
                }
            } catch {
                print("Failed to update task: \(error)")
                DispatchQueue.main.async {
                    onFailure(error)
                }
            }
        }
    }


    // Delete a task
    func deleteTask(task: TaskEntity, completion: @escaping () -> Void) {
        queue.async(flags: .barrier) {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                let tasks = try self.context.fetch(fetchRequest)
                if let taskToDelete = tasks.first {
                    self.context.delete(taskToDelete)
                    self.saveContext()
                } else {
                    print("Task not found")
                }
            } catch {
                print("Failed to delete task: \(error)")
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // Save the Core Data context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
            // Handle the error, e.g., show a SwiftUI alert
        }
    }
}



