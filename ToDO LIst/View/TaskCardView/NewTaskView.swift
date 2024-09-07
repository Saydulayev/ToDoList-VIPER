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
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var isStartTimeSet: Bool = false
    @State private var isEndTimeSet: Bool = false

    @State private var showErrorAlert = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Details", text: $details)
                }
                Section(header: Text("Task Time")) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .onChange(of: startTime) { _ in
                            isStartTimeSet = true
                        }
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .onChange(of: endTime) { _ in
                            isEndTimeSet = true
                        }
                }
                Section {
                    Button(taskToEdit == nil ? "Add Task" : "Save Changes") {
                        if let task = taskToEdit {
                            presenter.updateTask(task: TaskEntity(
                                id: task.id,
                                title: title,
                                details: details,
                                createdAt: task.createdAt,
                                startTime: isStartTimeSet ? startTime : nil,
                                endTime: isEndTimeSet ? endTime : nil,
                                isCompleted: task.isCompleted)
                            ) { success in
                                if success {
                                    isPresented = false
                                } else {
                                    errorMessage = "Another task with the same title already exists."
                                    showErrorAlert = true
                                }
                            }
                        } else {
                            presenter.addTask(
                                title: title,
                                details: details,
                                startTime: isStartTimeSet ? startTime : nil,
                                endTime: isEndTimeSet ? endTime : nil
                            ) { success in
                                if success {
                                    isPresented = false
                                } else {
                                    errorMessage = "Task with the same title already exists."
                                    showErrorAlert = true
                                }
                            }
                        }
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
                    if let taskStartTime = task.startTime {
                        startTime = taskStartTime
                        isStartTimeSet = true
                    }
                    if let taskEndTime = task.endTime {
                        endTime = taskEndTime
                        isEndTimeSet = true
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "An error occurred"), dismissButton: .default(Text("OK")))
            }
        }
    }
}



