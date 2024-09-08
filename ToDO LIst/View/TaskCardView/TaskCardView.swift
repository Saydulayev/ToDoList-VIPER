//
//  TaskCardView.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import SwiftUI
import CoreData

struct TaskCardView: View {
    var task: TaskEntity
    var presenter: TaskPresenter
    
    @State private var isExpanded: Bool = false 
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .gray : .black)
                        .font(.headline)
                        .lineLimit(isExpanded ? nil : 1)
                        .truncationMode(.tail)
                        .onTapGesture {
                            isExpanded.toggle()
                        }
                    Text(task.details)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .frame(height: 20)
                }
                Spacer()
                Button(action: {
                    presenter.toggleTaskCompletion(task: task)
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? .blue : .gray)
                        .font(.system(size: 24))
                }
                .buttonStyle(PlainButtonStyle())
            }
            Divider()
            HStack {
                Text("Today")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                
                HStack {
                    //Text("\(task.startTime ?? Date(), formatter: taskTimeFormatter) - \(task.endTime ?? Date(), formatter: taskTimeFormatter)")

                    Text("\(task.startTime ?? Date(), formatter: taskTimeFormatter) - \(task.endTime.map { taskTimeFormatter.string(from: $0) } ?? "N/A")")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.vertical, 5)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}



private let taskTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.locale = Locale.autoupdatingCurrent
    return formatter
}()
