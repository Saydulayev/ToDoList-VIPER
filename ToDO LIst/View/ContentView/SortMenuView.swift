//
//  SortMenuView.swift
//  ToDO LIst
//
//  Created by Saydulayev on 05.09.24.
//

import SwiftUI

struct SortMenuView: View {
    @ObservedObject var presenter: TaskPresenter

    var body: some View {
        Menu {
            sortButton(label: "Newest First", systemImage: "arrow.up", sortOrder: .newestFirst)
            sortButton(label: "Oldest First", systemImage: "arrow.down", sortOrder: .oldestFirst)
            sortButton(label: "A-Z", systemImage: "textformat.abc", sortOrder: .alphabeticalAZ)
            sortButton(label: "Z-A", systemImage: "textformat.abc", sortOrder: .alphabeticalZA)
        } label: {
            Image(systemName: "line.horizontal.3.decrease.circle")
                .styledAsMenuIcon()
        }
    }

    private func sortButton(label: String, systemImage: String, sortOrder: TaskSortOrder) -> some View {
        Button(action: {
            presenter.changeSortOrder(to: sortOrder)
        }) {
            Label(label, systemImage: systemImage)
        }
    }
}

private enum SortMenuConstants {
    static let menuIconFont: Font = .title2
    static let menuIconColor: Color = .blue
    static let menuIconPadding: CGFloat = 10
}

extension View {
    func styledAsMenuIcon() -> some View {
        self
            .font(SortMenuConstants.menuIconFont)
            .foregroundStyle(SortMenuConstants.menuIconColor)
            .padding(SortMenuConstants.menuIconPadding)
    }
}
