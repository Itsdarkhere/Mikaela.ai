//
//  AudioWaveFormView.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 16.4.2024.
//

import SwiftUI

struct AudioWaveFormView: View {
    var waveformData: [CGFloat]
    
    private let barWidth: CGFloat = 3
    private let spacing: CGFloat = 2
    
    var body: some View {
        HStack(spacing: spacing) {
            Spacer()
            if waveformData.count >= 6 {
                ForEach(waveformData.indices, id: \.self) { index in
                    BarView(value: waveformData[index])
                        .frame(width: barWidth)
                }
            }
            Spacer()
        }
    }
}

struct BarView: View {
    var value: CGFloat
    
    private let height: CGFloat = 30
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.red)
            .frame(height: value * height)
            .animation(.easeInOut(duration: 0.1), value: value)
    }
}

#Preview {
    AudioWaveFormView(waveformData: [
        CGFloat(0.2),
        CGFloat(0.6),
        CGFloat(0.3),
        CGFloat(0.4),
        CGFloat(0.1),
        CGFloat(0.7),
    ])
}
