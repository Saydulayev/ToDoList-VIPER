//
//  Models.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation


enum TaskFilter: String, CaseIterable {
    case all = "All"
    case open = "Open"
    case closed = "Closed"
}


enum TaskSortOrder {
    case newestFirst
    case oldestFirst
    case alphabeticalAZ
    case alphabeticalZA
}
