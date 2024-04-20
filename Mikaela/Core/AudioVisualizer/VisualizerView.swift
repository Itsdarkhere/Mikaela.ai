//
//  VisualizerViw.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 14.4.2024.
//

import SwiftUI

struct CircularVisualizer: Shape {
    var audioSamples: [CGFloat]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2 // Radius of the circle
        let center = CGPoint(x: rect.midX, y: rect.midY)
                
        guard !audioSamples.isEmpty else { return path }
            
        let angleStep = 2 * .pi / CGFloat(audioSamples.count)
                
        // Start from the top (12 o'clock position)
        var angle = -CGFloat.pi / 2
                
        // Move to the starting point
        let firstSample = max(audioSamples[0], 0.1) * radius
        let firstPoint = CGPoint(
            x: center.x + firstSample * cos(angle),
            y: center.y + firstSample * sin(angle)
        )
        path.move(to: firstPoint)

        // Add line segments for each sample
        for sample in audioSamples {
            let adjustedSample = max(sample, 0.1) * radius
            let point = CGPoint(
                x: center.x + adjustedSample * cos(angle),
                y: center.y + adjustedSample * sin(angle)
            )
            path.addLine(to: point)
            angle += angleStep
        }
                
        // Close the path by connecting back to the first point
        path.closeSubpath()

        return path
    }
}

struct AnimatedVisualizer: Shape {
    let audioSamples: [CGFloat]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let height = rect.height
        let width = rect.width / CGFloat(audioSamples.count)
        
        for i in 0 ..< audioSamples.count {
            let x = width * CGFloat(i)
            let y = CGFloat(audioSamples[i]) * height
            
            path.addRect(CGRect(x: x, y: 0, width: width, height: y))
        }
        
        return path
    }
}

struct VisualizerView: View {
    @State private var audioSamples: [CGFloat] = [0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.4, 0.4, 0.4]
    
    var body: some View {
        ZStack {
            CircularVisualizer(audioSamples: audioSamples)
                .fill(Color.red)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                .animation(Animation.easeInOut(duration: 0.2)
                    .repeatForever(autoreverses: true), value: audioSamples)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {
                timer in
                self.audioSamples = self.generateAudioSamples()
            }
        }
    }
    
    func generateAudioSamples() -> [CGFloat] {
        var samples: [CGFloat] = []
        for _ in 0...10 {
            samples.append(CGFloat.random(in: 0...1))
        }
        return samples
    }
}

#Preview {
    VisualizerView()
}
