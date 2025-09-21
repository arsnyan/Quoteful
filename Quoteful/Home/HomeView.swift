//
//  HomeView.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import SwiftUI
import FactoryKit

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            HomeGradientView()
            
            VStack {
                switch viewModel.quoteState {
                case .loading:
                    ProgressView()
                        .progressViewStyle(.circular)
                case .success(let quote):
                    Spacer()
                        .frame(maxHeight: 200)
                    Text(quote.quote)
                        .font(.custom("Cochin-BoldItalic", size: 32))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("© " + (quote.author))
                        .font(.custom("Cochin-Italic", size: 24))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Spacer()
                case .failure(let error):
                    Text("\(error.localizedDescription)")
                }
            }
            .padding(64)
        }
        .ignoresSafeArea()
        .task {
            await viewModel.fetchQuote()
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
