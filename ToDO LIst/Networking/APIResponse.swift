//
//  APIResponse.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import Foundation


struct APIResponse: Decodable {
    let todos: [APITask]
}



struct APITask: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}
