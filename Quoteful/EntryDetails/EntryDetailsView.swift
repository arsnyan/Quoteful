//
//  EntryDetailsView.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 21.09.2025.
//

import SwiftUI

struct EntryDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var text = ""
    
    @State private var selectedMood = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker(
                    "pickerMood",
                    selection: $selectedMood
                ) {
                    ForEach(Array(Mood.allCases.enumerated()), id: \.offset) { index, mood in
                        Text(mood.emojiRepresentation)
                            .tag(index)
                    }
                }
                .pickerStyle(.segmented)
                
                TextEditor(text: $text)
                    .textEditorStyle(.plain)
                    .contentMargins(.horizontal, 16)
                    .contentMargins(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .foregroundStyle(.mutedBeige)
                    )
            }
            .padding()
            .transition(.opacity)
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm) {
                            
                        }
                    } else {
                        Button("save") {
                            
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(!text.isEmpty)
    }
}

#Preview {
    EntryDetailsView()
}
