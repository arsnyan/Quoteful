//
//  AnimatedBackgroundView.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 22.09.2025.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: [Color]
    private let speed: CGFloat
    
    @State private var offsets: [CGSize]
    
    init(colors: [Color], speed: CGFloat) {
        self.colors = colors
        _offsets = State(initialValue: Array(repeating: .zero, count: colors.count))
        self.speed = speed
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.background.secondary)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                ZStack {
                    ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        Circle()
                            .fill(color.opacity(0.8))
                            .frame(width: geo.size.width * 0.85)
                            .offset(offsets[index])
                            .blendMode(colorScheme == .dark ? .screen : .multiply)
                    }
                }
                .position(
                    x: geo.size.width / CGFloat(Int.random(in: 1...4)),
                    y: geo.size.height / CGFloat(Int.random(in: 2...3))
                )
                .task {
                    for index in offsets.indices {
                        animateCircle(index: index, in: geo.size)
                    }
                }
            }
        }
    }
    
    private func animateCircle(index: Int, in size: CGSize) {
        let maxX = size.width * 0.4
        let maxY = size.height * 0.4
        
        func randomEdgePoint() -> CGSize {
            switch Int.random(in: 0..<4) {
            case 0: //top
                return CGSize(width: .random(in: -maxX...maxX), height: -maxY)
            case 1: // bottom
                return CGSize(width: .random(in: -maxX...maxX), height: maxY)
            case 2: // left
                return CGSize(width: -maxX, height: .random(in: -maxY...maxY))
            default: // right
                return CGSize(width: maxX, height: .random(in: -maxY...maxY))
            }
        }
        
        let destination = randomEdgePoint()
        
        let current = offsets[index]
        
        let distance = hypot(
            destination.width - current.width,
            destination.height - current.height
        )
        
        let travelTime = Double(distance / speed)
        
        withAnimation(.linear(duration: travelTime)) {
            offsets[index] = destination
        }
        
        Task {
            try await Task.sleep(for: .seconds(travelTime))
            animateCircle(index: index, in: size)
        }
    }
}

#Preview {
    AnimatedBackgroundView(colors: [
        .pink, .purple, .blue
    ], speed: 20)
}
