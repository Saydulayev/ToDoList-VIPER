//
//  NewTaskView.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import SwiftUI

struct NewTaskView: View {
    @Binding var isPresented: Bool
    @ObservedObject var presenter: TaskPresenter
    @Binding var taskToEdit: TaskEntity?

    @State private var title: String = ""
    @State private var details: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Details", text: $details)
                }
                Section {
                    Button(taskToEdit == nil ? "Add Task" : "Save Changes") {
                        if let task = taskToEdit {
                            presenter.updateTask(task: TaskEntity(id: task.id, title: title, details: details, createdAt: task.createdAt, isCompleted: task.isCompleted))
                        } else {
                            presenter.addTask(title: title, details: details)
                        }
                        isPresented = false
                    }
                    .disabled(title.count < 3)
                }
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            })
            .onAppear {
                if let task = taskToEdit {
                    title = task.title
                    details = task.details
                }
            }
        }
    }
}
