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
    
    func addTask(title: String, details: String) {
        interactor.addTask(title: title, details: details) { [weak self] in
            self?.loadTasks()
        }
    }
    
    func toggleTaskCompletion(task: TaskEntity) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        interactor.updateTask(task: updatedTask) { [weak self] in
            self?.loadTasks()
        }
    }
    
    func updateTask(task: TaskEntity) {
        interactor.updateTask(task: task) { [weak self] in
            self?.loadTasks()
        }
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
