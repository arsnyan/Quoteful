//
//  QuotefulRootView.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 21.09.2025.
//

import SwiftUI

@MainActor
enum TabItem: CaseIterable {
    case home, history, statistics
    
    var label: String {
        switch self {
        case .home:
            String(localized: "home")
        case .history:
            String(localized: "history")
        case .statistics:
            String(localized: "stats")
        }
    }
    
    var icon: String {
        switch self {
        case .home:
            "house.fill"
        case .history:
            "clock.fill"
        case .statistics:
            "chart.line.uptrend.xyaxis.circle.fill"
        }
    }
    
    @ViewBuilder func destination() -> some View {
        switch self {
        case .home:
            HomeView()
        case .history:
            HistoryView()
        case .statistics:
            StatisticsView()
        }
    }
}

struct QuotefulRootView: View {
    var body: some View {
        TabView {
            ForEach(TabItem.allCases, id: \.self) { item in
                Tab(item.label, systemImage: item.icon) {
                    item.destination()
                }
            }
        }
    }
}

#Preview {
    QuotefulRootView()
}
