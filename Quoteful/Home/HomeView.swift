//
//  HomeView.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import SwiftUI
import FactoryKit

struct HomeView: View {
    @InjectedObservable(\.homeViewModel) private var viewModel
    @State private var sheetPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                QuoteView(viewModel: $viewModel)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .padding([.horizontal], 64)
                    .padding([.vertical])
                
                SheetLikeView {
                    MockSheetInputBox(color: Color(red: 0.96, green: 0.94, blue: 0.90)) {
                        Label("writeThoughtsPlaceholder", systemImage: "pencil.line")
                            .accessibilityHidden(true)
                    }
                    
                    HStack {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Text(mood.emojiRepresentation)
                                .accessibilityHidden(true)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Circle().foregroundStyle(.gray.quinary))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(minHeight: 190)
                .onTapGesture {
                    sheetPresented.toggle()
                }
            }
            .animation(.easeInOut, value: viewModel.quoteState)
            .sheet(isPresented: $sheetPresented) {
                EntryDetailsView()
            }
            .navigationTitle("quoteOfTheDay")
            .background(HomeGradientView().ignoresSafeArea())
        }
        .task {
            await viewModel.fetchQuote()
        }
    }
}

fileprivate struct SheetLikeView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 64)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("FakeSheetClickableArea")
                .ignoresSafeArea(edges: .bottom)
                .foregroundStyle(.background)
                .shadow(color: .gray.opacity(0.25), radius: 10, y: -1)
            
            VStack(spacing: 16) {
                content
            }
            .padding(32)
        }
    }
}

fileprivate struct MockSheetInputBox<Content: View>: View {
    let color: Color
    let content: Content
    
    init(color: Color, @ViewBuilder _ content: () -> Content) {
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .frame(maxWidth: .infinity, maxHeight: 64)
            .foregroundStyle(color)
            .overlay {
                content
            }
    }
}

fileprivate struct QuoteView: View {
    @Binding var viewModel: HomeViewModel
    
    var body: some View {
        switch viewModel.quoteState {
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .transition(.opacity)
        case .success(let quote):
            VStack {
                Text(quote.quote)
                    .font(.custom("Cochin-BoldItalic", size: 32))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("© " + (quote.author))
                    .font(.custom("Cochin-Italic", size: 24))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .transition(.opacity.combined(with: .scale))
        case .failure(let errorDescription):
            Text(errorDescription)
                .transition(.opacity.combined(with: .scale))
        }
    }
}

fileprivate struct HomeGradientView: View {
    let softCream = Color(red: 0.96, green: 0.94, blue: 0.90)
    let mutedBeige = Color(red: 0.87, green: 0.82, blue: 0.76)
    let offWhite = Color(red: 0.98, green: 0.97, blue: 0.95)
    let warmTan = Color(red: 0.82, green: 0.76, blue: 0.69)
    let lightGray = Color(red: 0.92, green: 0.92, blue: 0.92)
    
    var body: some View {
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.35, 0.0], [1.0, 0.0],
                    [0.0, 0.55], [0.65, 0.45], [1.0, 0.5],
                    [0.0, 1.0], [0.4, 1.0], [1.0, 1.0]
                ],
                colors: [
                    offWhite,   softCream,  warmTan,
                    lightGray,  mutedBeige, offWhite,
                    softCream,  warmTan,    mutedBeige
                ]
            )
        } else {
            LinearGradient(
                gradient: Gradient(colors: [softCream, mutedBeige]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    HomeView()
}
