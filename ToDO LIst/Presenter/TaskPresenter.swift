//
//  TaskPresenter.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation

class TaskPresenter: TaskPresenterProtocol {
    @Published var tasks: [TaskEntity] = []
    
    private let interactor: TaskInteractorProtocol
    private let userDefaultsKey = "hasLoadedTasksFromAPI"
    private var sortOrder: TaskSortOrder = .newestFirst
    
    init(interactor: TaskInteractorProtocol) {
        self.interactor = interactor
        loadTasks()
    }
    
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
    
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, completion: @escaping (Bool) -> Void) {
        interactor.addTask(title: title, details: details, startTime: startTime, endTime: endTime, onSuccess: { [weak self] in
            self?.loadTasks()
            completion(true)
        }, onFailure: { error in
            completion(false)
        })
    }
    
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

    func updateTask(task: TaskEntity, completion: @escaping (Bool) -> Void) {
        interactor.updateTask(task: task, onSuccess: { [weak self] in
            self?.loadTasks()
            completion(true)
        }, onFailure: { error in
            completion(false)
        })
    }
    
    func deleteTask(task: TaskEntity) {
        interactor.deleteTask(task: task) { [weak self] in
            self?.loadTasks()
        }
    }

    func changeSortOrder(to newSortOrder: TaskSortOrder) {
        sortOrder = newSortOrder
        sortAndAssignTasks(tasks)
    }
    
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


