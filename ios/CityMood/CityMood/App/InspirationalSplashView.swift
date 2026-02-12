//
//  InspirationalSplashView.swift
//  CityMood
//
//  Created by Henry Feynman on 2026-02-11.
//  Copyright © 2026 Feynman. All rights reserved.
//

import SwiftUI

struct InspirationalSplashView: View {
    @State private var textOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 30
    @State private var backgroundOpacity: Double = 0.0
    @State private var isExiting = false
    @State private var exitOpacity: Double = 1.0
    @State private var exitScale: CGFloat = 1.0
    @State private var selectedQuote = Quote.random()
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // 中国水墨画风格背景
            InkWashBackground()
                .opacity(backgroundOpacity)
            
            // 淡墨纹理叠加
            InkTextureOverlay()
                .opacity(backgroundOpacity * 0.6)
            
            // 内容层
            VStack(spacing: 24) {
                Spacer()
                
                // 装饰性印章
                SealStamp()
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                
                // Quote text - 减小字体
                VStack(spacing: 16) {
                    Text(selectedQuote.text)
                        .font(.system(size: 22, weight: .light, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                        .lineSpacing(8)
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                    
                    Text("— \(selectedQuote.author) —")
                        .font(.system(size: 14, weight: .ultraLight))
                        .foregroundColor(.white.opacity(0.85))
                        .tracking(2)
                        .opacity(textOpacity * 0.8)
                        .offset(y: textOffset)
                }
                .padding(.horizontal, 50)
                
                Spacer()
                
                // 进入提示
                VStack(spacing: 8) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .thin))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                    
                    Text("轻触进入")
                        .font(.system(size: 12, weight: .ultraLight))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(4)
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                }
                .padding(.bottom, 60)
            }
        }
        .opacity(exitOpacity)
        .scaleEffect(exitScale)
        .onAppear {
            // 背景淡入
            withAnimation(.easeOut(duration: 1.2)) {
                backgroundOpacity = 1.0
            }
            
            // 文字延迟淡入
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 1.0)) {
                    textOpacity = 1.0
                    textOffset = 0
                }
            }
        }
        .onTapGesture {
            guard !isExiting else { return }
            isExiting = true
            
            // 优雅的退出动画 - 淡出并轻微放大
            withAnimation(.easeIn(duration: 0.6)) {
                exitOpacity = 0.0
                exitScale = 1.05
            }
            
            // 动画完成后回调
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onComplete()
            }
        }
    }
}

// MARK: - 中国水墨画背景
struct InkWashBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 基础渐变 - 宣纸色调
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.93, blue: 0.88), // 米白
                        Color(red: 0.88, green: 0.85, blue: 0.78), // 暖灰
                        Color(red: 0.75, green: 0.72, blue: 0.65)  // 深暖灰
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 水墨晕染效果
                InkBlot(color: Color.black.opacity(0.15), size: 400, offset: CGPoint(x: -80, y: -100))
                InkBlot(color: Color(red: 0.2, green: 0.2, blue: 0.25).opacity(0.2), size: 350, offset: CGPoint(x: 150, y: 200))
                InkBlot(color: Color.black.opacity(0.1), size: 300, offset: CGPoint(x: -100, y: 400))
                InkBlot(color: Color(red: 0.15, green: 0.15, blue: 0.2).opacity(0.18), size: 450, offset: CGPoint(x: 120, y: -50))
                
                // 远山淡墨
                DistantMountain(opacity: 0.12)
                    .offset(y: geometry.size.height * 0.3)
                
                DistantMountain(opacity: 0.08)
                    .offset(y: geometry.size.height * 0.35)
                
                // 暗角效果
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.2)
                    ]),
                    center: .center,
                    startRadius: geometry.size.width * 0.3,
                    endRadius: geometry.size.width * 0.8
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

// MARK: - 墨渍组件
struct InkBlot: View {
    let color: Color
    let size: CGFloat
    let offset: CGPoint
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        color,
                        color.opacity(0.5),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size)
            .offset(x: offset.x, y: offset.y)
            .blur(radius: size * 0.3)
            .scaleEffect(pulseScale)
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    pulseScale = 1.1
                }
            }
    }
}

// MARK: - 远山轮廓
struct DistantMountain: View {
    let opacity: Double
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height * 0.4
                
                path.move(to: CGPoint(x: 0, y: height * 0.6))
                
                // 连绵的山峰
                var x: CGFloat = 0
                while x < width {
                    let peakHeight = CGFloat.random(in: 0.3...0.8) * height
                    let peakX = x + CGFloat.random(in: 50...150)
                    let nextX = peakX + CGFloat.random(in: 80...200)
                    
                    path.addQuadCurve(
                        to: CGPoint(x: nextX, y: height * 0.6),
                        control: CGPoint(x: peakX, y: height * 0.6 - peakHeight)
                    )
                    
                    x = nextX
                }
                
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(Color.black.opacity(opacity))
            .blur(radius: 8)
        }
    }
}

// MARK: - 墨纹理叠加
struct InkTextureOverlay: View {
    var body: some View {
        Canvas { context, size in
            // 绘制随机墨点
            for _ in 0..<30 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let radius = CGFloat.random(in: 2...8)
                let opacity = Double.random(in: 0.03...0.1)
                
                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(Color.black.opacity(opacity)))
            }
        }
    }
}

// MARK: - 印章装饰
struct SealStamp: View {
    var body: some View {
        ZStack {
            // 印章边框
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.red.opacity(0.7), lineWidth: 2)
                .frame(width: 44, height: 44)
            
            // 印章文字
            Text("心境")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.red.opacity(0.8))
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Quote Data
struct Quote: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let author: String
    
    static func random() -> Quote {
        let quotes: [Quote] = [
            // 中文古典诗词
            Quote(text: "海内存知己，天涯若比邻", author: "王勃"),
            Quote(text: "山川异域，风月同天", author: "长屋王"),
            Quote(text: "春风又绿江南岸，明月何时照我还", author: "王安石"),
            Quote(text: "采菊东篱下，悠然见南山", author: "陶渊明"),
            Quote(text: "行到水穷处，坐看云起时", author: "王维"),
            Quote(text: "竹杖芒鞋轻胜马，谁怕？一蓑烟雨任平生", author: "苏轼"),
            Quote(text: "人生到处知何似，应似飞鸿踏雪泥", author: "苏轼"),
            Quote(text: "此情可待成追忆，只是当时已惘然", author: "李商隐"),
            Quote(text: "山重水复疑无路，柳暗花明又一村", author: "陆游"),
            Quote(text: "问君能有几多愁，恰似一江春水向东流", author: "李煜"),
            
            // 现代中文
            Quote(text: "我们就是我们居住的城市", author: "CityMood"),
            Quote(text: "每一次心跳，都在绘制城市的轮廓", author: "CityMood"),
            Quote(text: "你的心情，是这座城市最温柔的色彩", author: "CityMood"),
            Quote(text: "万家灯火，每一盏都是一个故事", author: "CityMood"),
            
            // 西方经典
            Quote(text: "We are all in the gutter, but some of us are looking at the stars", author: "Oscar Wilde"),
            Quote(text: "The happiness of your life depends upon the quality of your thoughts", author: "Marcus Aurelius"),
            Quote(text: "In the middle of difficulty lies opportunity", author: "Albert Einstein"),
            Quote(text: "One small positive thought in the morning can change your whole day", author: "Dalai Lama"),
        ]
        
        return quotes.randomElement() ?? quotes[0]
    }
}

#Preview {
    InspirationalSplashView(onComplete: {})
}