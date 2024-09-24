//
//  HeaderView.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import SwiftUI

struct HeaderView: View {
    let dateFormatter: DateFormatter
    @Binding var showNewTaskForm: Bool
    @Binding var editingTask: TaskEntity?
    @ObservedObject var presenter: TaskPresenter

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: HeaderViewConstants.vStackSpacing) {
                Text("Today's Task")
                    .font(HeaderViewConstants.titleFont)
                    .fontWeight(.bold)
                Text("\(Date(), formatter: dateFormatter)")
                    .font(HeaderViewConstants.subtitleFont)
                    .foregroundStyle(.gray)
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
                .styledAsPrimaryButton()
            }
            .sheet(isPresented: $showNewTaskForm) {
                NewTaskView(isPresented: $showNewTaskForm, presenter: presenter, taskToEdit: $editingTask)
            }
        }
        .padding(.horizontal, HeaderViewConstants.horizontalPadding)
    }
}

// Константы для параметров верстки в HeaderView
private enum HeaderViewConstants {
    static let vStackSpacing: CGFloat = 4
    static let titleFont: Font = .title
    static let subtitleFont: Font = .subheadline
    static let horizontalPadding: CGFloat = 16
}

extension View {
    func styledAsPrimaryButton() -> some View {
        self
            .bold()
            .padding(.vertical, ButtonConstants.verticalPadding)
            .padding(.horizontal, ButtonConstants.horizontalPadding)
            .background(Color.blue.opacity(ButtonConstants.backgroundOpacity))
            .foregroundColor(.blue)
            .clipShape(RoundedRectangle(cornerRadius: ButtonConstants.cornerRadius))
    }
}

// Константы для параметров стилизации кнопок
private enum ButtonConstants {
    static let verticalPadding: CGFloat = 10
    static let horizontalPadding: CGFloat = 15
    static let backgroundOpacity: Double = 0.1
    static let cornerRadius: CGFloat = 15
}
