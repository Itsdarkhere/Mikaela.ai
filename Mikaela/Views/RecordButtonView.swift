//
//  RecordButtonView.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 16.4.2024.
//

import SwiftUI
import SwiftData

struct RecordButtonView: View {
    @Environment(\.modelContext) private var context
    @Environment(AudioRecorder.self) private var audioRecorder: AudioRecorder
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray, lineWidth: 3)
                .frame(width: 60, height: 60)
            Button(action: {
                withAnimation(.easeOut(duration: 0.3)) {
                    if !audioRecorder.isRecording {
                        audioRecorder.record()
                    } else {
                        audioRecorder.stopRecording { fileName in
                            guard let fileName = fileName else {
                                print("The recording file is unavailable")
                                return
                            }
                            
                            let uuid = UUID().uuidString
                            let newTitle = "New recording"
                            let transcript = "New transcript"
                            
                            let recording = Recording(id: uuid, title: newTitle, fileName: fileName, transcript: transcript, createdAt: Date())
                            
                            // store in state
                            context.insert(recording)
                            
                            do {
                                try context.save()
                            } catch {
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }, label: {
                if audioRecorder.isRecording {
                    AudioWaveFormView(waveformData: audioRecorder.audioPowerData)
                        .frame(width: 28, height: 30)
                } else {
                    Image(systemName: "mic")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                }
            })
        }
    }
}

#Preview("Idle state") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recording.self, configurations: config)
    let audioRecorder = AudioRecorder()
    
    return RecordButtonView()
        .environment(audioRecorder)
        .modelContainer(container)
}

#Preview("Recording state") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recording.self, configurations: config)
    let audioRecorder = AudioRecorder()
    
    audioRecorder.isRecording = true
    audioRecorder.audioPowerData = [0.3, 0.2, 0.4, 0.8, 0.5, 0.3]
    
    return RecordButtonView()
        .environment(audioRecorder)
        .modelContainer(container)
}
