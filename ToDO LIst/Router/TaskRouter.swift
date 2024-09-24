//
//  TaskRouter.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import SwiftUI


//struct TaskRouter {
//    static func createModule() -> some View {
//        let interactor = TaskInteractor()
//        let presenter = TaskPresenter(interactor: interactor)
//        return ContentView(presenter: presenter)
//    }
//}

struct TaskModuleBuilder {
    static func createModule() -> some View {
        let interactor = TaskInteractor()
        let router = TaskRouter() // Создаем роутер
        let presenter = TaskPresenter(interactor: interactor, router: router) // Передаем роутер презентеру
        
        return ContentView(presenter: presenter)
    }
}


final class TaskRouter: ObservableObject { // TaskRouter должен быть ObservableObject
    @Published var showTaskDetail = false
    var selectedTask: TaskEntity?

    // Навигация к детальному экрану задачи
    func navigateToTaskDetail(task: TaskEntity) {
        selectedTask = task
        showTaskDetail = true
    }
}
