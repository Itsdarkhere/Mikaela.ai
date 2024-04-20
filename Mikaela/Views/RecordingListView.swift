//
//  RecordingListView.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 15.4.2024.
//

import SwiftUI
import SwiftData

struct RecordingListView: View {
    @Environment(\.modelContext) private var context
    @Environment(AudioRecorder.self) private var audioRecorder
    
    @Query(sort: \Recording.createdAt, order: .reverse) var allRecordings: [Recording]
    
    var body: some View {
        @Bindable var audioRecorder = audioRecorder
        
        ZStack {
            if (allRecordings.isEmpty) {
                ContentUnavailableView("You dont have any recordings yet", systemImage: "Waveform")
            } else {
                List {
                    ForEach(allRecordings) {
                        recording in VStack(alignment: .leading, spacing: 10) {
                            Text(recording.title)
                                .font(.headline)
                            Text(format(date: recording.createdAt, format: "dd/MM//yy HH:mm"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(recording.transcript)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            context.delete(allRecordings[index])
                        }
                        
                        do {
                            try context.save()
                        } catch {
                            print("Error \(error.localizedDescription)")
                        }
                    }
                }
                .padding(.bottom, 96)
                .listStyle(PlainListStyle())
            }
            
            VStack {
                Spacer(minLength: 0)
                VStack(alignment: .center) {
                    RecordButtonView()
                }
                .padding(.bottom, 0)
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .background(Color(UIColor.systemGray6))
            }
        }
        .alert(isPresented: $audioRecorder.showMicAccessAlert) {
            Alert(title: Text("Required microphone access!!"), message: Text("Go to settings > <AppName> > Allow <AppName> to access Microphone. \nSet switch to enable."), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recording.self,
        configurations: config)
    let audioRecorder = AudioRecorder()
    
    for i in 1..<10 {
        let recording = Recording(id: UUID().uuidString, title: "New recording \(i)", fileName: "recording\(i).wav", transcript: "This is recording: \(i)", createdAt: Date())
        container.mainContext.insert(recording)
    }
    
    return NavigationStack {
        RecordingListView()
            .navigationTitle("Recordings")
        }
        .task {
            audioRecorder.setup()
        }
        .environment(audioRecorder)
        .modelContainer(container)
}
