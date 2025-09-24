//
//  EntryDetailsView.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 21.09.2025.
//

import SwiftUI

struct EntryDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable private var viewModel: EntryDetailsViewModel
    
    @FocusState private var isEditorFocused: Bool
    
    @Namespace private var namespace
    
    init(viewModel: EntryDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                switch viewModel.state {
                case .editing(let data):
                    EditingEntry(viewModel: data, isEditorFocused: $isEditorFocused, namespace: namespace)
                case .viewing(let entry):
                    ViewingEntry(entry: entry, namespace: namespace)
                }
            }
            .padding()
            .overlay(Background())
            .animation(.easeInOut, value: viewModel.state)
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture { isEditorFocused.toggle() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    switch viewModel.state {
                    case .editing(let data):
                        SaveButton(data: data)
                    case .viewing:
                        StartEditingButton()
                    }
                }
            }
        }
        .interactiveDismissDisabled(!viewModel.isDismissable)
    }
    
    @ViewBuilder private func Background() -> some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .stroke(lineWidth: 4)
                .fill(.thinMaterial)
                .ignoresSafeArea()
        } else {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 4)
                .fill(.thinMaterial)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder private func SaveButton(data: EntryDetailsViewModelEditingData) -> some View {
        if #available(iOS 26.0, *) {
            Button(role: .confirm) {
                Task {
                    await viewModel.saveEntry {
                        dismiss()
                    } animatableHandler: {
                        withAnimation(.easeInOut) {
                            viewModel.toggleEditMode()
                        }
                    }
                }
            }
            .sensoryFeedback(.error, trigger: data.savingError)
        } else {
            Button("save") {
                Task {
                    await viewModel.saveEntry {
                        dismiss()
                    } animatableHandler: {
                        withAnimation(.easeInOut) {
                            viewModel.toggleEditMode()
                        }
                    }
                }
            }
            .sensoryFeedback(.error, trigger: data.savingError)
        }
    }
    
    @ViewBuilder private func StartEditingButton() -> some View {
        if #available(iOS 26.0, *) {
            Button {
                withAnimation(.easeInOut) {
                    viewModel.toggleEditMode()
                }
            } label: {
                Image(systemName: "pencil")
            }
        } else {
            Button("edit") {
                viewModel.toggleEditMode()
            }
        }
    }
}

private struct EditingEntry: View {
    @Bindable var viewModel: EntryDetailsViewModelEditingData
    
    @FocusState.Binding var isEditorFocused: Bool
    
    var namespace: Namespace.ID
    
    var body: some View {
        HStack {
            ForEach(Mood.allCases, id: \.self) { mood in
                Button {
                    viewModel.selectedMood = mood
                } label: {
                    Text(mood.emojiRepresentation)
                        .font(.largeTitle)
                        .accessibilityHidden(true)
                        .frame(maxWidth: .infinity)
                        .background {
                            if viewModel.selectedMood == mood {
                                Circle()
                                    .foregroundStyle(.tint)
                                    .matchedGeometryEffect(id: "selectedMood", in: namespace)
                            }
                        }
                        .matchedGeometryEffect(id: mood.emojiRepresentation, in: namespace)
                        .animation(.interpolatingSpring(mass: 0.3, stiffness: 627, damping: 52), value: viewModel.selectedMood)
                }
                .buttonStyle(.plain)
            }
        }
        
        VStack(alignment: .leading) {
            TextEditor(text: $viewModel.textInput)
                .focused($isEditorFocused)
                .textEditorStyle(.plain)
                .contentMargins(.horizontal, 16)
                .contentMargins(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .foregroundStyle(.mutedBeige)
                )
                .sensoryFeedback(.error, trigger: viewModel.textEmptyError)
            
            if viewModel.textInput.isEmpty, viewModel.textEmptyError {
                Text("Text field should not be empty")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal)
            }
        }
        .animation(.spring(duration: 0.5, bounce: 0.2), value: viewModel.textEmptyError)
    }
}

private struct ViewingEntry: View {
    var entry: JournalEntry
    
    var namespace: Namespace.ID
    
    var body: some View {
        HStack {
            Text(entry.mood.emojiRepresentation)
                .font(.largeTitle)
                .matchedGeometryEffect(id: entry.mood.emojiRepresentation, in: namespace)
            
            VStack {
                Text(entry.timestamp, style: .date)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                Text(entry.timestamp, style: .time)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        }
        
        TextEditor(text: .constant(entry.text))
            .textEditorStyle(.plain)
            .contentMargins(.horizontal, 16)
            .contentMargins(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .foregroundStyle(.mutedBeige)
            )
    }
}

#Preview {
    EntryDetailsView(
        viewModel: EntryDetailsViewModel(
            entry: JournalEntry(timestamp: .now, mood: .angry, text: "Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros")
        )
    )
}
