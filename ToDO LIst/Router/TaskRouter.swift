//
//  TaskRouter.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import SwiftUI


struct TaskRouter {
    static func createModule() -> some View {
        let interactor = TaskInteractor()
        let presenter = TaskPresenter(interactor: interactor)
        return ContentView(presenter: presenter)
    }
}
