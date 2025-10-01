//
//  HomeView.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import SwiftUI
import FactoryKit
import Translation

struct HomeView: View {
    @InjectedObservable(\.homeViewModel) private var viewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                QuoteView(viewModel: $viewModel)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .padding([.horizontal], 64)
                    .padding([.vertical])
                
                SheetRectangle(color: .mutedBeige)
                    .frame(minHeight: 190)
                    .ignoresSafeArea(edges: .bottom)
                    .onTapGesture { viewModel.sheetTapped() }
                    .sensoryFeedback(.error, trigger: viewModel.feedbackWarning)
                    .sensoryFeedback(.success, trigger: viewModel.feedbackSuccess)
            }
            .animation(
                .interpolatingSpring(mass: 0.9, stiffness: 260, damping: 30),
                value: viewModel.quoteState
            )
            .navigationTitle("quoteOfTheDay")
            .background(
                HomeBackgroundView(
                    colors: [.mutedBeige, .offWhite, .softCream, .warmTan],
                    speed: 40
                )
            )
            .sheet(isPresented: $viewModel.sheetPresented) {
                EntryDetailsView(viewModel: EntryDetailsViewModel())
                    .presentationBackground(.softCream)
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.fraction(0.75), .large])
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchQuote()
            }
        }
    }
}

fileprivate struct SheetRectangle: View {
    let color: Color
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 64)
                .frame(maxWidth: .infinity)
                .accessibilityHint("openSheetCreateEntryHint")
                .accessibilityLabel("clickableAreaAccessibilityLabel")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("FakeSheetClickableArea")
                .foregroundStyle(.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 64)
                        .stroke(lineWidth: 2)
                        .fill(.thinMaterial)
                        .foregroundStyle(.offWhite)
                )
            
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 32)
                    .frame(maxWidth: .infinity, maxHeight: 64)
                    .foregroundStyle(color)
                    .shadow(color: .mutedBeige, radius: 8)
                    .overlay {
                        Label("writeThoughtsPlaceholder", systemImage: "pencil.line")
                            .symbolEffect(
                                .wiggle.clockwise.byLayer,
                                options: .repeat(.periodic(delay: 4.0))
                            )
                            .tint(.primary)
                            .accessibilityHidden(true)
                    }
                
                HStack {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Text(mood.emojiRepresentation)
                            .accessibilityHidden(true)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Circle().foregroundStyle(.gray.tertiary))
                    }
                }
            }
            .padding(32)
        }
    }
}

fileprivate struct HomeBackgroundView: View {
    let colors: [Color]
    let speed: CGFloat
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(
                colors: colors,
                speed: speed
            )
            .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 64, style: .continuous)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .overlay(
                    RoundedRectangle(cornerRadius: 64, style: .continuous)
                        .stroke(lineWidth: 4)
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                )
        }
    }
}

struct QuoteView: View {
    @Binding var viewModel: HomeViewModel
    
    @Namespace private var animation
    
    @Environment(\.locale) private var currentLocale
    
    var body: some View {
        switch viewModel.quoteState {
        case .loading:
            VStack {
                Text("..............................")
                    .font(.custom("Cochin-BoldItalic", size: 32))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .matchedGeometryEffect(id: "Author", in: animation)
                Text("...............")
                    .font(.custom("Cochin-Italic", size: 24))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .skeleton(isRedacted: true)
            .transition(.identity)
        case .success(let quote):
            VStack {
                Text(verbatim: quote.quote)
                    .font(.custom("Cochin-BoldItalic", size: 32))
                    .minimumScaleFactor(0.5)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .matchedGeometryEffect(id: "QuoteText", in: animation)
                    .translationPresentation(isPresented: $viewModel.translationVisible, text: quote.quote)
                Text("© " + (quote.author))
                    .font(.custom("Cochin-Italic", size: 24))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .matchedGeometryEffect(id: "Author", in: animation)
                
                if !currentLocale.language.isEquivalent(to: Locale.Language(identifier: "en")) {
                    Spacer()
                        .frame(height: 24)
                    
                    Button(action: { viewModel.translationVisible.toggle() }) {
                        Label("translateQuote", systemImage: "translate")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.mutedBeige)
                }
            }
            .skeleton(isRedacted: false)
            .transition(.identity)
        case .failure(let errorDescription):
            Text(errorDescription)
                .matchedGeometryEffect(id: "QuoteText", in: animation)
                .transition(.identity)
        }
    }
}
