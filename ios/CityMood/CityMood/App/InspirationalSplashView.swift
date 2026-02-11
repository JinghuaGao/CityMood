//
//  InspirationalSplashView.swift
//  CityMood
//
//  Created by Henry Feynman on 2026-02-11.
//  Copyright © 2026 Feynman. All rights reserved.
//

import SwiftUI

struct InspirationalSplashView: View {
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.3
    @State private var showMainContent = false
    @State private var selectedQuote = Quote.random()
    
    var body: some View {
        ZStack {
            // Watercolor background (ink painting style)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.3, blue: 0.5),  // Deep ink blue
                    Color(red: 0.4, green: 0.5, blue: 0.7),  // Soft watercolor fade
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .overlay(
                // Subtle watercolor blobs for artistic effect
                WatercolorBlob()
                    .scaleEffect(1.2)
                    .opacity(0.3)
                    .blendMode(.overlay),
                alignment: .bottomLeading
            )
            
            VStack(spacing: 40) {
                Spacer()
                
                // Quote text
                VStack(spacing: 20) {
                    Text(selectedQuote.text)
                        .font(.system(.title, design: .serif))
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .opacity(opacity)
                        .scaleEffect(scale)
                        .padding(.horizontal, 40)
                    
                    Text(selectedQuote.author)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                }
                
                Spacer()
                
                // Subtle continue indicator (avoiding direct social elements)
                Text("Tap to feel the city's pulse...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                opacity = 1.0
                scale = 1.0
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.8)) {
                showMainContent = true
            }
        }
        .fullScreenCover(isPresented: $showMainContent) {
            MainContentView()  // Replace with your actual main view
        }
    }
}

// MARK: - Quote Data
struct Quote: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let author: String
    
    static func random() -> Quote {
        let quotes: [Quote] = [
            // Original concept quotes
            Quote(text: "We are the city, we are the world", author: "CityMood"),
            Quote(text: "Every heart's whisper shapes the streets we walk", author: "CityMood"),
            Quote(text: "Your mood is the city's ink, painting the map of tomorrow", author: "CityMood"),
            
            // Chinese classical poetry (translated/adapted)
            Quote(text: "海内存知己，天涯若比邻", author: "王勃 - 王维"),
            Quote(text: "山川异域，风月同天", author: "张九龄"),
            Quote(text: "春风又绿江南岸，明月何时照我还", author: "王维"),
            
            // Western philosophy/poetry
            Quote(text: "We are all in the gutter, but some of us are looking at the stars", author: "Oscar Wilde"),
            Quote(text: "The world is indeed full of peril, and in it there are many dark places; but still there is much that is fair", author: "J.R.R. Tolkien"),
            Quote(text: "To be yourself in a world that is constantly trying to make you something else is the greatest accomplishment", author: "Ralph Waldo Emerson"),
            
            // Art-inspired (Monet's lilies influence)
            Quote(text: "I perhaps owe having become a painter to flowers", author: "Claude Monet"),
            Quote(text: "The richness I achieve comes from Nature, the source of my inspiration", author: "Claude Monet"),
            
            // Modern inspirational
            Quote(text: "One small positive thought in the morning can change your whole day", author: "Dalai Lama"),
            Quote(text: "The happiness of your life depends upon the quality of your thoughts", author: "Marcus Aurelius"),
            Quote(text: "In the middle of difficulty lies opportunity", author: "Albert Einstein")
        ]
        
        return quotes.randomElement() ?? quotes[0]
    }
}

// MARK: - Watercolor Effect Component
struct WatercolorBlob: View {
    @State private var phase: Double = 0
    
    var body: some View {
        TimelineView(.animation) { context in
            Canvas { context, size in
                // Create organic ink blob shapes
                let path = createWatercolorPath(context: context, size: size)
                
                // Multiple layers for depth
                context.fill(
                    Path(path),
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color(red: 0.1, green: 0.15, blue: 0.3).opacity(0.6),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                
                // Edge bleeding effect
                context.stroke(
                    Path(path),
                    with: .color(.white.opacity(0.2)),
                    lineWidth: 2
                )
            }
            .frame(width: 300, height: 200)
            .offset(x: -50, y: 150)
        }
        .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: phase)
    }
    
    private func createWatercolorPath(context: GraphicsContext, size: CGSize) -> Path {
        var path = Path()
        
        // Organic, irregular shape
        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        let randomness: CGFloat = 0.3
        
        // Create blob outline using bezier curves with noise
        let points = 8
        var currentPoint = CGPoint(x: center.x, y: center.y - 80)
        
        path.move(to: currentPoint)
        
        for i in 1...points {
            let angle = (CGFloat(i) / CGFloat(points)) * 2 * .pi
            let radius = 80 + (randomness * 40 * (sin(angle * 3) + 1))
            
            let nextPoint = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            
            // Add organic curve control points
            let control1 = CGPoint(
                x: currentPoint.x + (nextPoint.x - currentPoint.x) * 0.3,
                y: currentPoint.y + (nextPoint.y - currentPoint.y) * 0.3
            )
            let control2 = CGPoint(
                x: nextPoint.x - (nextPoint.x - currentPoint.x) * 0.3,
                y: nextPoint.y - (nextPoint.y - currentPoint.y) * 0.3
            )
            
            path.addCurve(
                to: nextPoint,
                control1: control1,
                control2: control2
            )
            
            currentPoint = nextPoint
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Main Content Placeholder
struct MainContentView: View {
    var body: some View {
        // Your existing main app content
        Text("CityMood Main Content")
            .font(.title)
            .padding()
    }
}

#Preview {
    InspirationalSplashView()
}
