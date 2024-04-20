//
//  recordView.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 12.4.2024.
//

import SwiftUI
import SwiftUI
import AVFoundation

struct recordView: View {
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    
    var body: some View {
        VStack {
            Text(isRecording ? "recording..." : "tap to record")
            Button(action: toggleRecording) {
                Image(systemName: isRecording ? "stop.circle" : "record.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
        }
        .onAppear(perform: setupRecorder)
    }
    
    private func setupRecorder() {
        let audioFileName = getDocumentsDirectory()
            .appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch {
            print("Failed to setup recorder \(error)")
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            audioRecorder?.stop()
        } else {
            audioRecorder?.record()
        }
        isRecording.toggle()
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
}

#Preview {
    recordView()
}
