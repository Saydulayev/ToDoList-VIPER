//
//  HeaderView.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import  SwiftUI


struct HeaderView: View {
    let dateFormatter: DateFormatter
    @Binding var showNewTaskForm: Bool
    @Binding var editingTask: TaskEntity?
    @ObservedObject var presenter: TaskPresenter

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Task")
                    .font(.title)
                    .fontWeight(.bold)
                Text("\(Date(), formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                editingTask = nil
                showNewTaskForm.toggle()
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("New Task")
                }
                .bold()
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(15)
            }
            .sheet(isPresented: $showNewTaskForm) {
                NewTaskView(isPresented: $showNewTaskForm, presenter: presenter, taskToEdit: $editingTask)
            }
        }
        .padding(.horizontal)
    }
}
