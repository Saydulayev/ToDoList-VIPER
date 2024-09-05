//
//  ToDO_LIstApp.swift
//  ToDO LIst
//
//  Created by Saydulayev on 03.09.24.
//

import SwiftUI

@main
struct ToDO_LIstApp: App {
    var body: some Scene {
        WindowGroup {
            TaskRouter.createModule()
                .preferredColorScheme(.light)
        }
    }
}
