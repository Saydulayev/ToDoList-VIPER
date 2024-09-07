//
//  TaskInteractorProtocol.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation

protocol TaskInteractorProtocol {
    func fetchTasks(completion: @escaping ([TaskEntity]) -> Void)
    func fetchTasksFromAPI(completion: @escaping ([TaskEntity]) -> Void)
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void)
    func updateTask(task: TaskEntity, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void)
    func deleteTask(task: TaskEntity, completion: @escaping () -> Void)
}


