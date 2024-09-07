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
    var startTime: Date? 
    var endTime: Date?
    var isCompleted: Bool
}


