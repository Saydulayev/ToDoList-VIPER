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
class TaskInteractor: TaskInteractorProtocol {
    private let context = PersistenceController.shared.viewContext
    private let queue = DispatchQueue(label: "com.todoApp.taskQueue", attributes: .concurrent)
    
    // Fetch tasks from Core Data
    /// Извлекает задачи из Core Data и возвращает их в виде массива `TaskEntity`.
    ///
    /// Метод выполняется асинхронно на фоновом потоке, чтобы не блокировать основной поток.
    /// В случае успешного извлечения задач, массив `TaskEntity` передается в замыкании `completion`.
    /// Если произошла ошибка или задачи не были найдены, возвращается пустой массив.
    ///
    /// - Parameter completion: Замыкание, которое вызывается с массивом `TaskEntity` после завершения операции.
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


    /// Извлекает задачи из удаленного API и сохраняет их в Core Data.
    ///
    /// Метод отправляет запрос к указанному API для получения списка задач. Полученные задачи декодируются
    /// из формата JSON и сохраняются в Core Data. После завершения операции массив задач передается через замыкание `completion`.
    /// В случае ошибки или отсутствия данных возвращается пустой массив.
    ///
    /// - Parameter completion: Замыкание, которое вызывается с массивом `TaskEntity` после завершения операции.
    func fetchTasksFromAPI(completion: @escaping ([TaskEntity]) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            // Отправляем запрос к API
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
    /// Сохраняет массив задач в Core Data, избегая дублирования по заголовку.
    ///
    /// Метод проходит по каждой задаче в массиве и проверяет, существует ли уже задача с таким же заголовком в базе данных.
    /// Если задачи с таким заголовком нет, то создается новая запись в Core Data.
    /// Все операции выполняются асинхронно на фоне, с использованием `barrier`, чтобы избежать состояния гонки.
    ///
    /// - Parameter tasks: Массив задач типа `TaskEntity`, которые нужно сохранить в Core Data.
    private func saveTasksToCoreData(tasks: [TaskEntity]) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            tasks.forEach { taskEntity in
                // Проверяем, существует ли уже задача с таким заголовком, чтобы избежать дублирования
                let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "title == %@", taskEntity.title)
                
                do {
                    let existingTasks = try self.context.fetch(fetchRequest)
                    if existingTasks.isEmpty {
                        // Если задач с таким заголовком нет, создаем новую задачу
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
            // Сохраняем изменения в контексте Core Data
            self.saveContext()
        }
    }



    // Add a new task
    /// - Parameters:
    ///   - title: Заголовок задачи. Не должен быть пустым или дублироваться.
    ///   - details: Подробное описание задачи.
    ///   - startTime: Время начала задачи. Необязательное поле.
    ///   - endTime: Время окончания задачи. Необязательное поле.
    ///   - onSuccess: Замыкание, которое вызывается при успешном добавлении задачи.
    ///   - onFailure: Замыкание, которое вызывается при возникновении ошибки. Возвращает объект `Error`.
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
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
    /// Обновляет существующую задачу в Core Data, проверяя на наличие другой задачи с таким же заголовком.
    ///
    /// Этот метод асинхронно обновляет задачу в Core Data. Сначала он проверяет, существует ли другая задача с таким же заголовком,
    /// чтобы избежать дублирования. Если дубликатов нет, задача обновляется. Если задача с таким же заголовком существует,
    /// операция отклоняется.
    ///
    /// - Parameters:
    ///   - task: Объект `TaskEntity`, представляющий задачу, которую необходимо обновить.
    ///   - onSuccess: Замыкание, вызываемое при успешном обновлении задачи.
    ///   - onFailure: Замыкание, вызываемое при возникновении ошибки или если задача с таким заголовком уже существует. Возвращает объект `Error?`.
    func updateTask(task: TaskEntity, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
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
                        // Обновляем задачу, если дубликатов нет
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
                        // Если задача с таким заголовком уже существует, вызываем onFailure
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
    /// Удаляет задачу из Core Data.
    /// 
    /// Метод асинхронно удаляет задачу из базы данных Core Data. Сначала он пытается найти задачу по ее идентификатору.
    /// Если задача найдена, она удаляется из контекста Core Data. Если задача не найдена или возникает ошибка при удалении,
    /// соответствующее сообщение выводится в консоль. После завершения операции вызывается замыкание `completion`.
    /// 
    /// - Parameters:
    ///   - task: Объект `TaskEntity`, представляющий задачу, которую необходимо удалить.
    ///   - completion: Замыкание, вызываемое после завершения операции удаления, независимо от того, была ли задача найдена и удалена.
    func deleteTask(task: TaskEntity, completion: @escaping () -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                let tasks = try self.context.fetch(fetchRequest)
                if let taskToDelete = tasks.first {
                    // Если задача найдена, удаляем её из контекста
                    self.context.delete(taskToDelete)
                    self.saveContext()
                } else {
                    // Если задача не найдена, выводим сообщение в консоль
                    print("Task not found")
                }
            } catch {
                // Логируем ошибку, если что-то пошло не так при удалении
                print("Failed to delete task: \(error)")
            }

            // Вызов completion после завершения операции
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



