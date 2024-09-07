//
//  TaskPresenter.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation

/// Презентер для управления задачами в приложении.
///
/// `TaskPresenter` отвечает за получение, добавление, обновление и удаление задач.
/// Он взаимодействует с `TaskInteractor` для выполнения операций с данными и
/// обновляет интерфейс пользователя при изменении данных.
class TaskPresenter: TaskPresenterProtocol {
    @Published var tasks: [TaskEntity] = []
    
    private let interactor: TaskInteractorProtocol
    private let userDefaultsKey = "hasLoadedTasksFromAPI"
    private var sortOrder: TaskSortOrder = .newestFirst
    
    /// Инициализирует новый экземпляр `TaskPresenter`.
    ///
    /// - Parameter interactor: Экземпляр `TaskInteractorProtocol`, который будет использоваться для выполнения операций с задачами.
    init(interactor: TaskInteractorProtocol) {
        self.interactor = interactor
        loadTasks()
    }
    
    /// Загружает задачи, используя кэшированные данные или данные из API.
    ///
    /// Если задачи уже загружались ранее, они извлекаются из Core Data.
    /// В противном случае задачи загружаются из API и сохраняются в Core Data.
    func loadTasks() {
        let hasLoadedTasksFromAPI = UserDefaults.standard.bool(forKey: userDefaultsKey)
        
        if hasLoadedTasksFromAPI {
            interactor.fetchTasks { [weak self] tasks in
                DispatchQueue.main.async {
                    self?.sortAndAssignTasks(tasks)
                }
            }
        } else {
            interactor.fetchTasksFromAPI { [weak self] tasks in
                DispatchQueue.main.async {
                    self?.sortAndAssignTasks(tasks)
                    UserDefaults.standard.set(true, forKey: self?.userDefaultsKey ?? "")
                }
            }
        }
    }
    
    /// Добавляет новую задачу.
    ///
    /// - Parameters:
    ///   - title: Заголовок задачи.
    ///   - details: Подробности задачи.
    ///   - startTime: Время начала задачи (необязательное).
    ///   - endTime: Время окончания задачи (необязательное).
    ///   - completion: Замыкание, вызываемое при завершении операции. Возвращает `true`, если задача была успешно добавлена, или `false`, если произошла ошибка.
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, completion: @escaping (Bool) -> Void) {
        interactor.addTask(title: title, details: details, startTime: startTime, endTime: endTime, onSuccess: { [weak self] in
            self?.loadTasks()
            completion(true)
        }, onFailure: { error in
            completion(false)
        })
    }
    
    /// Переключает статус выполнения задачи.
    ///
    /// - Parameter task: Задача, статус выполнения которой нужно изменить.
    func toggleTaskCompletion(task: TaskEntity) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()

        interactor.updateTask(task: updatedTask, onSuccess: { [weak self] in
            guard let self = self else { return }
            
            if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                self.tasks[index] = updatedTask
            }

            self.loadTasks()
        }, onFailure: { error in
            print("Failed to toggle task completion: \(error?.localizedDescription ?? "Unknown error")")
        })
    }

    /// Обновляет существующую задачу.
    ///
    /// - Parameters:
    ///   - task: Задача, которую нужно обновить.
    ///   - completion: Замыкание, вызываемое при завершении операции. Возвращает `true`, если задача была успешно обновлена, или `false`, если произошла ошибка.
    func updateTask(task: TaskEntity, completion: @escaping (Bool) -> Void) {
        interactor.updateTask(task: task, onSuccess: { [weak self] in
            self?.loadTasks()
            completion(true)
        }, onFailure: { error in
            completion(false)
        })
    }
    
    /// Удаляет задачу.
    ///
    /// - Parameter task: Задача, которую нужно удалить.
    func deleteTask(task: TaskEntity) {
        interactor.deleteTask(task: task) { [weak self] in
            self?.loadTasks()
        }
    }

    /// Изменяет порядок сортировки задач.
    ///
    /// - Parameter newSortOrder: Новый порядок сортировки.
    func changeSortOrder(to newSortOrder: TaskSortOrder) {
        sortOrder = newSortOrder
        sortAndAssignTasks(tasks)
    }
    
    /// Фильтрует задачи по выбранному фильтру.
    ///
    /// - Parameter filter: Фильтр для задач (`all`, `open`, `closed`).
    /// - Returns: Отфильтрованный массив задач.
    func filteredTasks(for filter: TaskFilter) -> [TaskEntity] {
        switch filter {
        case .all:
            return tasks
        case .open:
            return tasks.filter { !$0.isCompleted }
        case .closed:
            return tasks.filter { $0.isCompleted }
        }
    }

    /// Сортирует и присваивает задачи в зависимости от текущего порядка сортировки.
    ///
    /// - Parameter tasks: Массив задач для сортировки и присвоения.
    private func sortAndAssignTasks(_ tasks: [TaskEntity]) {
        switch sortOrder {
        case .newestFirst:
            self.tasks = tasks.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            self.tasks = tasks.sorted { $0.createdAt < $1.createdAt }
        case .alphabeticalAZ:
            self.tasks = tasks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .alphabeticalZA:
            self.tasks = tasks.sorted { $0.title.lowercased() > $1.title.lowercased() }
        }
    }
}


