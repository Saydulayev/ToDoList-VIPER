//
//  TaskPresenterProtocol.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation


protocol TaskPresenterProtocol: ObservableObject {
    func loadTasks()
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?)
    func toggleTaskCompletion(task: TaskEntity)
    func updateTask(task: TaskEntity)
    func deleteTask(task: TaskEntity)
}

