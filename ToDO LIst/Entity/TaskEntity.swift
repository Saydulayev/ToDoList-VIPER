//
//  TaskEntity.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation

struct TaskEntity: Identifiable {
    let id: UUID
    var title: String
    var details: String
    let createdAt: Date
    var startTime: Date? // Добавлено поле startTime
    var endTime: Date?   // Добавлено поле endTime
    var isCompleted: Bool
}


