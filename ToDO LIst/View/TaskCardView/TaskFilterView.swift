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
            filterDivider()
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
                filterCapsule(count: count, isSelected: selectedFilter == filter)
            }
            .styledAsFilterButton(isSelected: selectedFilter == filter)
        }
        .animation(.none, value: selectedFilter)
    }

    private func filterCapsule(count: Int, isSelected: Bool) -> some View {
        Capsule()
            .fill(isSelected ? FilterConstants.selectedColor : FilterConstants.deselectedColor)
            .frame(width: FilterConstants.capsuleWidth, height: FilterConstants.capsuleHeight)
            .overlay(
                Text("\(count)")
                    .font(.footnote)
                    .foregroundStyle(.white)
            )
    }

    private func filterDivider() -> some View {
        Divider()
            .frame(width: FilterConstants.dividerWidth, height: FilterConstants.dividerHeight)
            .background(Color.gray)
            .padding(.horizontal, FilterConstants.dividerPadding)
    }
}

private extension View {
    func styledAsFilterButton(isSelected: Bool) -> some View {
        self
            .font(.subheadline)
            .fontWeight(isSelected ? .bold : .regular)
            .foregroundStyle(isSelected ? .blue : .gray)
            .padding(.vertical, 15)
            .padding(.horizontal, 5)
    }
}


private enum FilterConstants {
    static let verticalPadding: CGFloat = 15
    static let horizontalPadding: CGFloat = 5
    static let capsuleWidth: CGFloat = 25
    static let capsuleHeight: CGFloat = 20
    static let selectedColor = Color.blue
    static let deselectedColor = Color.gray.opacity(0.3)
    static let dividerWidth: CGFloat = 1
    static let dividerHeight: CGFloat = 20
    static let dividerPadding: CGFloat = 10
}
