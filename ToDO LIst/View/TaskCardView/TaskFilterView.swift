//
//  TaskFilterView.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import SwiftUI

struct TaskFilterView: View {
    @Binding var selectedFilter: TaskFilter
    var allCount: Int
    var openCount: Int
    var closedCount: Int
    
    var body: some View {
        HStack {
            filterButton(title: "All", count: allCount, filter: .all)
            Divider()
                .frame(width: 1, height: 20)
                .background(Color.gray)
                .padding(.horizontal, 10)
            filterButton(title: "Open", count: openCount, filter: .open)
            filterButton(title: "Closed", count: closedCount, filter: .closed)
        }
        .padding(.horizontal)
    }
    
    private func filterButton(title: String, count: Int, filter: TaskFilter) -> some View {
        Button(action: {
            withAnimation(.none) {
                selectedFilter = filter
            }
        }) {
            HStack {
                Text(title)
                Capsule()
                    .fill(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 25, height: 20)
                    .overlay(
                        Text("\(count)")
                            .font(.footnote)
                            .foregroundStyle(.white)
                    )
            }
            .font(.subheadline)
            .fontWeight(selectedFilter == filter ? .bold : .regular)
            .foregroundStyle(selectedFilter == filter ? .blue : .gray)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 5)
        .animation(.none, value: selectedFilter)
    }
}
