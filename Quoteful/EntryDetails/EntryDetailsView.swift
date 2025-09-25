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
    
    // TODO: - test the view model and the ui layer
    
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
                ToolbarItem(placement: .navigation) {
                    Button {
                        withAnimation(.snappy) {
                            if viewModel.hasUnsavedChanges {
                                viewModel.showDiscardDialog = true
                            } else {
                                dismiss()
                            }
                        }
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "chevron.left")
                                .accessibilityHidden(true)
                        } else {
                            Label("back", systemImage: "chevron.left")
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityLabel("back")
                    .accessibilityIdentifier("BackButton")
                    .confirmationDialog(
                        "discardChanges",
                        isPresented: $viewModel.showDiscardDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Discard", role: .destructive) { dismiss() }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("hasUnsavedChanges")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    switch viewModel.state {
                    case .editing(let data):
                        SaveButton(data: data) {
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
                        .accessibilityIdentifier("SaveButton")
                    case .viewing:
                        StartEditingButton() {
                            withAnimation(.easeInOut) {
                                viewModel.toggleEditMode()
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden()
        }
        .onAppear {
            viewModel.resetToViewingState()
        }
        .onDisappear {
            viewModel.resetToViewingState()
        }
        .interactiveDismissDisabled(!viewModel.isDismissable)
    }
    
    @ViewBuilder private func Background() -> some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .stroke(lineWidth: 4)
                .fill(.thinMaterial)
                .ignoresSafeArea()
                .accessibilityHidden(true)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 4)
                .fill(.thinMaterial)
                .ignoresSafeArea()
                .accessibilityHidden(true)
        }
    }
    
    @ViewBuilder private func SaveButton(data: EntryDetailsViewModelEditingData, action: @escaping () -> Void) -> some View {
        if #available(iOS 26.0, *) {
            Button(role: .confirm, action: action)
                .sensoryFeedback(.error, trigger: data.savingError)
        } else {
            Button("save", action: action)
                .sensoryFeedback(.error, trigger: data.savingError)
        }
    }
    
    @ViewBuilder private func StartEditingButton(action: @escaping () -> Void) -> some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                Image(systemName: "pencil")
            }
        } else {
            Button("edit", action: action)
        }
    }
}

private struct EditingEntry: View {
    @Bindable var viewModel: EntryDetailsViewModelEditingData
    
    @FocusState.Binding var isEditorFocused: Bool
    
    var namespace: Namespace.ID
    
    var body: some View {
        HStack {
            ForEach(Array(Mood.allCases.enumerated()), id: \.offset) { index, mood in
                Button {
                    viewModel.selectedMood = mood
                } label: {
                    Text(mood.emojiRepresentation)
                        .font(.largeTitle)
                        .accessibilityLabel(mood.emojiRepresentation)
                        .accessibilityHint("emojiSelectionHint")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("emoji\(index)")
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
                .accessibilityIdentifier("EntryTextEditor")
                .accessibilityLabel("editEntryTextAccessibilityLabel")
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .foregroundStyle(.mutedBeige)
                        .accessibilityHidden(true)
                )
                .offset(x: viewModel.savingError ? 20 : 0)
                .sensoryFeedback(.error, trigger: viewModel.textEmptyError)
                .onChange(of: viewModel.savingError) { _, newValue in
                    if newValue {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2)) {
                            viewModel.savingError = false
                        }
                    }
                }
            
            if viewModel.textInput.isEmpty, viewModel.textEmptyError {
                Text("textEmptyError")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal)
                    .accessibilityHint("errorHintAccessibility")
                    .accessibilityIdentifier("ContextualErrorMsg")
                    .offset(x: viewModel.shakeTextEmpty ? 20 : 0)
                    .onChange(of: viewModel.shakeTextEmpty) { _, newValue in
                        if newValue {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2)) {
                                viewModel.shakeTextEmpty = false
                            }
                        }
                    }
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
                .accessibilityLabel(entry.mood.emojiRepresentation)
                .accessibilityIdentifier(entry.mood.emojiRepresentation)
                .accessibilityHint("entrySelectedMoodAccessibilityLabel")
                .matchedGeometryEffect(id: entry.mood.emojiRepresentation, in: namespace)
            
            VStack {
                Text(entry.timestamp, style: .date)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .accessibilityLabel("entryDateAccessibilityLabel")
                Text(entry.timestamp, style: .time)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                    .accessibilityLabel("entryTimeAccessibilityLabel")
            }
        }
        
        ScrollView {
            Text(entry.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHint("entryTextAccessibilityLabel")
        }
        .textEditorStyle(.plain)
        .contentMargins(.horizontal, 21)
        .contentMargins(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(.mutedBeige)
        )
    }
}

#Preview {
    EntryDetailsView(
        viewModel: EntryDetailsViewModel(
            entry: JournalEntry(
                timestamp: .now,
                mood: .confused,
                text: "Test"
            )
        )
    )
}
