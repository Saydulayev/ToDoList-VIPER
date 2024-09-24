//
//  TaskCardView.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import SwiftUI

struct TaskCardView: View {
    var task: TaskEntity
    var presenter: TaskPresenter
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .styledAsTaskTitle(completed: task.isCompleted)
                        .onTapGesture {
                            isExpanded.toggle()
                        }
                    Text(task.details)
                        .styledAsTaskDetails()
                }
                Spacer()
                Button(action: {
                    presenter.toggleTaskCompletion(task: task)
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .styledAsCompletionButton(completed: task.isCompleted)
                }
                .buttonStyle(PlainButtonStyle())
            }
            Divider()
            HStack {
                Text("Today")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                
                HStack {
                    Text("\(task.startTime ?? Date(), formatter: taskTimeFormatter) - \(task.endTime.map { taskTimeFormatter.string(from: $0) } ?? "N/A")")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.vertical, 5)
        }
        .styledAsTaskCard()
    }
}

private let taskTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.locale = Locale.autoupdatingCurrent
    return formatter
}()


extension View {
    func styledAsTaskCard() -> some View {
        self
            .padding(TaskCardConstants.cardPadding)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: TaskCardConstants.cardCornerRadius))
            .shadow(color: Color.black.opacity(0.1), radius: TaskCardConstants.cardShadowRadius, x: 0, y: 5)
    }
    
    func styledAsTaskTitle(completed: Bool) -> some View {
        self
            .strikethrough(completed)
            .foregroundStyle(completed ? .gray : .black)
            .font(TaskCardConstants.taskTitleFont)
            .lineLimit(1)
            .truncationMode(.tail)
    }
    
    func styledAsTaskDetails() -> some View {
        self
            .font(TaskCardConstants.taskDetailsFont)
            .foregroundStyle(.gray)
            .frame(height: 20)
    }
    
    func styledAsCompletionButton(completed: Bool) -> some View {
        self
            .foregroundStyle(completed ? .blue : .gray)
            .font(.system(size: TaskCardConstants.completionButtonSize))
    }
}

private enum TaskCardConstants {
    static let cardPadding: CGFloat = 20
    static let cardCornerRadius: CGFloat = 12
    static let cardShadowRadius: CGFloat = 5
    static let taskTitleFont: Font = .headline
    static let taskDetailsFont: Font = .subheadline
    static let completionButtonSize: CGFloat = 24
}
