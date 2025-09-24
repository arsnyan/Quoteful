//
//  HistoryViewModel.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 24.09.2025.
//

import Foundation
import GRDB
import FactoryKit

@Observable
class HistoryViewModel {
    @ObservationIgnored
    @Injected(\.dbPool) private var dbPool
    
    var entries: [JournalEntry] = []
    
    func startTrackingEntries() async {
        guard let dbPool else { return }
        
        let observation = ValueObservation.tracking(JournalEntry.fetchAll)
        
        do {
            for try await entries in observation.values(in: dbPool) {
                self.entries = entries
            }
        } catch {
            print(error)
        }
    }
}

extension Container {
    var historyViewModel: Factory<HistoryViewModel> {
        self {
            HistoryViewModel()
        }
        .singleton
    }
}
