//
//  P10.swift
//  HEXWatch
//
//  Created by abhishekbabladi on 2025-02-08.
//


import SwiftUI
import Combine

public struct P10_CircleTypography: View {
    
    @StateObject private var intervalStore = TimeIntervalStore()
    @State private var texts: [String] = [
        "ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎㄲㄸㅃㅆㅉㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎㄲㄸㅃㅆㅉ",
        "ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎㄲㄸㅃㅆㅉㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎㄲㄸㅃㅆㅉ",
        "ㄱㄲㄳㄴㄵㄶㄷㄸㄹㄺㄻㄼㄽㄾㄿㅀㅁㅂㅃㅄㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ",
        "ㄱㄲㄳㄴㄵㄶㄷㄸㄹㄺㄻㄼㄽㄾㄿㅀㅁㅂㅃㅄㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ"
    ]
    
    public init() {}
    
    public var body: some View {
        CircleTypography(texts: $texts)
            .environmentObject(intervalStore)
            .background(Color.clear)
            .rotation3DEffect(.degrees(sin(intervalStore.time) * 100), axis: (x: 0, y: 0, z: 1))
            .animation(.default, value: intervalStore.time)
            .onAppear {
                DispatchQueue.main.async {
                    intervalStore.start()
                }
            }
    }
}

fileprivate struct CircleText: View {
    var isDynamic: Bool
    var sec: Double
    var text: String
    var gap: CGFloat
    
    var body: some View {
        GeometryReader { proxy in
            let minSize = min(proxy.size.width, proxy.size.height) // ✅ Fix: Replaced minSize
            
            ZStack(alignment: .center) {
                ForEach(Array(text.enumerated()), id: \.offset) { index, element in
                    Text(String(element))
                        .font(.custom("Helvetica Bold", fixedSize: getFontSize(minSize)))
                        .rotation3DEffect(isDynamic ? .degrees(cos(sec) * 60) : .degrees(0), axis: (x: 0, y: 0, z: 1))
                        .offset(y: -(minSize / 2 - gap))
                        .rotationEffect(.degrees(Double(index) / Double(text.count)) * 360)
                }
            }
            .rotationEffect(.degrees(Double(sec) / Double(text.count)) * 360)
            .offset(x: proxy.size.width / 2 - getFontSize(minSize) / 2, y: proxy.size.height / 2 - getFontSize(minSize) / 2)
        }
    }
    
    private func getFontSize(_ minSize: CGFloat) -> CGFloat {
        return minSize / 2 * 0.1
    }
}

extension P10_CircleTypography {
    
    struct CircleTypography: View {
        @EnvironmentObject var store: TimeIntervalStore
        @Binding var texts: [String]
        
        private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // ✅ Improved timer
        
        var body: some View {
            ZStack {
                ForEach(1..<(texts.count + 1), id: \.self) { index in
                    getContent(index)
                        .opacity((CGFloat(texts.count) - CGFloat(index - 1)) * 0.2)
                }
            }
        }
        
        private func getFontSize(_ minSize: CGFloat) -> CGFloat {
            return minSize / 2 * 0.1
        }
        
        private func getContent(_ index: Int) -> some View {
            GeometryReader { proxy in
                let minSize = min(proxy.size.width, proxy.size.height) // ✅ Fix
                
                if index % 2 == 1 {
                    CircleText(isDynamic: true, sec: store.time * Double(index), text: texts[index - 1], gap: getFontSize(minSize) * CGFloat(index))
                        .foregroundColor(Color.red)
                } else {
                    CircleText(isDynamic: false, sec: store.time * -Double(index), text: texts[index - 1], gap: getFontSize(minSize) * CGFloat(index))
                        .foregroundColor(Color.green)
                }
            }
        }
    }
    
    class TimeIntervalStore: ObservableObject {
        
        @Published var isStart: Bool = false
        @Published var time: Double = 0
        @Published var circleTime: Double = 0
        @Published var prevImage: Image = Image(systemName: "network")
        @Published var nextImage: Image = Image(systemName: "globe.asia.australia.fill")
        
        @Published var prevColor: Color = Color(hex: 0x000000)
        @Published var nextColor: Color = Color(hex: 0x5586A2)
        @Published var interval: Double = 0.1
        
        private var currentImageIndex: Int = 0
        private var images = ["globe.asia.australia.fill", "globe.americas", "network"]
        private var colors = [
            Color(hex: 0x5586A2), Color(hex: 0xF6D256), Color(hex: 0x0C4C89),
            Color(hex: 0xEF562D), Color(hex: 0x97D5E0)
        ]
        
        private var timerCancellable: AnyCancellable? // ✅ Uses Combine instead of Timer
        
        init(interval: Double = 0.1) {
            self.interval = interval
        }
        
        func start() {
            timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    self.run()
                }
        }
        
        func stop() {
            time = 0
            timerCancellable?.cancel()
        }
        
        func pause() {
            timerCancellable?.cancel()
        }
        
        func changeImage() {
            prevImage = Image(systemName: images.first ?? "network")
            nextImage = Image(systemName: images.dropFirst().first ?? "globe.asia.australia.fill")

            images.append(images.removeFirst())
            colors.append(colors.removeFirst())

            prevColor = colors.first ?? Color.black
            nextColor = colors.dropFirst().first ?? Color.gray
        }
        
        private func run() {
            time += interval
            circleTime += interval
            if Int(circleTime) == 60 {
                circleTime = 0
                DispatchQueue.main.async {
                    self.changeImage()
                }
            }
        }
    }
}

struct P10_CircleTypography_Previews: PreviewProvider {
    static var previews: some View {
        P10_CircleTypography()
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
