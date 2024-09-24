//
//  ContentView.swift
//  ToDO LIst
//
//  Created by Saydulayev on 03.09.24.
//

import CoreData
import SwiftUI


struct ContentView: View {
    @ObservedObject var presenter: TaskPresenter
    @State private var selectedFilter: TaskFilter = .all
    @State private var showNewTaskForm: Bool = false
    @State private var editingTask: TaskEntity? = nil
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading) {
            HeaderView(
                dateFormatter: dateFormatter,
                showNewTaskForm: $showNewTaskForm,
                editingTask: $editingTask,
                presenter: presenter
            )

            HStack {
                TaskFilterView(
                    selectedFilter: $selectedFilter,
                    allCount: presenter.tasks.count,
                    openCount: presenter.tasks.filter { !$0.isCompleted }.count,
                    closedCount: presenter.tasks.filter { $0.isCompleted }.count
                )
                Spacer()
                SortMenuView(presenter: presenter)
            }

            TaskListView(
                presenter: presenter,
                selectedFilter: $selectedFilter,
                showNewTaskForm: $showNewTaskForm,
                editingTask: $editingTask
            )
        }
        .background(Constants.backgroundColor) 
    }
}

private enum Constants {
    static let backgroundColor = Color(UIColor.systemGroupedBackground)
}

#Preview {
    let interactor = TaskInteractor()
    let presenter = TaskPresenter(interactor: interactor, router: TaskRouter())
    ContentView(presenter: presenter)
}


