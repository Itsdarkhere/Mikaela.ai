//
//  DemoView.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 15.4.2024.
//

import SwiftUI
import SwiftData

struct DemoView: View {
    var audioRecorder = AudioRecorder()
    var body: some View {
        NavigationStack {
            RecordingListView()
                .navigationTitle("Recordings")
        }
        .task {
            audioRecorder.setup()
        }
        .environment(audioRecorder)
        .modelContainer(for: [
            Recording.self
        ])
    }
}

#Preview {
    DemoView()
}
