//
//  TaskInteractor.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation
import CoreData


/// TaskInteractor отвечает за управление задачами (TaskEntity) в приложении.
/// Он предоставляет функциональность для создания, обновления, удаления и загрузки задач как из локальной базы данных (Core Data),
/// так и из удаленного API. Все операции выполняются асинхронно с использованием GCD, что обеспечивает
/// неконкурентное выполнение задач в фоновом режиме и предотвращает блокировку основного потока.
/// Это позволяет приложению оставаться отзывчивым, даже при выполнении длительных операций с данными.
final class TaskInteractor: TaskInteractorProtocol {
    
    // Используем общие константы для строковых значений
    private enum Constants {
        static let taskQueueLabel = "com.todoApp.taskQueue"
        static let titlePredicateFormat = "title == %@"
        static let idPredicateFormat = "id == %@"
        static let apiUrl = "https://dummyjson.com/todos"
    }
    
    private let context = PersistenceController.shared.viewContext
    private let queue = DispatchQueue(label: Constants.taskQueueLabel, attributes: .concurrent)
    
    // Fetch tasks from Core Data
    func fetchTasks(completion: @escaping ([TaskEntity]) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
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

    // Fetch tasks from API
    func fetchTasksFromAPI(completion: @escaping ([TaskEntity]) -> Void) {
        guard let url = URL(string: Constants.apiUrl) else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        queue.async { [weak self] in
            guard let self = self else { return }
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            tasks.forEach { taskEntity in
                let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: Constants.titlePredicateFormat, taskEntity.title)
                
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: Constants.titlePredicateFormat, title)
            
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: Constants.idPredicateFormat, task.id as CVarArg)
            
            do {
                let tasks = try self.context.fetch(fetchRequest)
                if let taskToUpdate = tasks.first {
                    let titleCheckRequest: NSFetchRequest<Task> = Task.fetchRequest()
                    titleCheckRequest.predicate = NSPredicate(format: "\(Constants.titlePredicateFormat) AND id != %@", task.title, task.id as CVarArg)
                    
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: Constants.idPredicateFormat, task.id as CVarArg)
            
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
        }
    }
}



