//
//  TaskListView.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var presenter: TaskPresenter
    @Binding var selectedFilter: TaskFilter
    @Binding var showNewTaskForm: Bool
    @Binding var editingTask: TaskEntity?
    
    @State private var showAlert = false
    @State private var taskToDelete: TaskEntity?

    var body: some View {
        List {
            ForEach(filteredTasks(), id: \.id) { task in
                TaskCardView(task: task, presenter: presenter)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .contextMenu {
                        contextMenuButtons(for: task)
                    }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color(UIColor.systemGroupedBackground))
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Task"),
                message: Text("Are you sure you want to delete this task?"),
                primaryButton: .destructive(Text("Yes")) {
                    if let taskToDelete = taskToDelete {
                        presenter.deleteTask(task: taskToDelete)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func filteredTasks() -> [TaskEntity] {
        return presenter.filteredTasks(for: selectedFilter)
    }

    private func contextMenuButtons(for task: TaskEntity) -> some View {
        Group {
            Button(action: {
                editingTask = task
                showNewTaskForm.toggle()
            }) {
                Text("Edit")
                Image(systemName: "pencil")
            }
            Button(role: .destructive) {
                taskToDelete = task
                showAlert.toggle()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}


