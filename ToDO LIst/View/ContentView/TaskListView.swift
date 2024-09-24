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
                    .listRowBackground(TaskListViewConstants.listRowBackgroundColor)
                    .listRowSeparator(.hidden)
                    .contextMenu {
                        TaskContextMenu(
                            task: task,
                            onEdit: {
                                editingTask = task
                                showNewTaskForm.toggle()
                            },
                            onDelete: {
                                taskToDelete = task
                                showAlert.toggle()
                            }
                        )
                    }
            }
        }
        .listStyle(PlainListStyle())
        .background(TaskListViewConstants.listBackgroundColor)
        .alert(isPresented: $showAlert) {
            taskDeleteAlert
        }
    }

    private func filteredTasks() -> [TaskEntity] {
        return presenter.filteredTasks(for: selectedFilter)
    }

    private var taskDeleteAlert: Alert {
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

private struct TaskContextMenu: View {
    var task: TaskEntity
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        Group {
            Button(action: onEdit) {
                Text("Edit")
                Image(systemName: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// Константы для параметров верстки TaskListView
private enum TaskListViewConstants {
    static let listRowBackgroundColor = Color.clear
    static let listBackgroundColor = Color(UIColor.systemGroupedBackground)
}

