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
                presenter.deleteTask(task: task)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

