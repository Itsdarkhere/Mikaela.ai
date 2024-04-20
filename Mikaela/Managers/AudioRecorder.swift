//
//  AudioRecorder.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 16.4.2024.
//

import Foundation
import AVFoundation

@Observable
class AudioRecorder: NSObject {
    var isRecording = false
    var hasMicAccess = false
    var showMicAccessAlert = false
    var audioPowerData: [CGFloat] = []
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var timer: Timer?
    
    private func requestMicrophoneAccess() {
        AVAudioApplication.requestRecordPermission { granted in
            if granted {
                self.hasMicAccess = true
            } else {
                self.showMicAccessAlert = true
            }
        }
    }
    
    private func normalizeAudioPower(power: Float) -> CGFloat {
        let minDb: Float = -80.0
        if power < minDb { return 0.0 }
        if power > 1.0 { return 1.0 }
        
        return CGFloat((abs(minDb) - abs(power)) / abs(minDb))
    }
    
    private func updateWaveForm() {
        guard let recorder = self.audioRecorder else { return }
        
        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        self.audioPowerData.append(normalizeAudioPower(power: averagePower))
        
        // we only have 6 'bars'
        if self.audioPowerData.count > 6 {
            self.audioPowerData.removeFirst()
        }
    }
    
    func setup() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            self.audioRecorder = try AVAudioRecorder(url: FileSystemManager.getRecordingTempUrl(), settings: settings)
            self.audioRecorder?.isMeteringEnabled = true
            self.audioRecorder?.delegate = self
            
            self.requestMicrophoneAccess()
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func record() {
        if hasMicAccess {
            self.audioPowerData.removeAll()
            self.audioRecorder?.record()
            self.isRecording = true
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.updateWaveForm()
            }
        } else {
            self.requestMicrophoneAccess()
        }
    }
    
    func stopRecording(completion: (String?) -> Void) {
        self.audioRecorder?.stop()
        
        let fileName = FileSystemManager.saveRecordingFile()
        
        completion(fileName)
        
        self.isRecording = false
    }
    
    
    
    
    // VJX CODE 
    // Used like
    // askForAudio(prompt: "Hello sexy sir or madame") { data in
    //   guard let data = data else { return }
    //        DispatchQueue.main.async {
    //            playAudio(from: data)
    //        }
    //    }
    
    func askForAudio(prompt: String, completion: @escaping (Data?) -> Void) {
        print("Ask for audio!")
        guard let url = URL(string: "https://live-laugh-learn.vercel.app/api/chatvoice") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["prompt": prompt]
        request.httpBody = try? JSONEncoder().encode(body)
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }
    
    func playAudio(from data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    func askForText(completion: @escaping (String) -> Void) {
            print("Ask for text!")
            // Define the URL
            guard let url = URL(string: "https://live-laugh-learn.vercel.app/api/chatmessage") else {
                print("Invalid URL")
                return
            }
        
            let messageHistory = [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": "Hey how you doing?"]
            ]

            let requestData: [String: Any] = [
                "messages": messageHistory
            ]
            
            // Convert requestData to JSON
            guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData) else {
                print("Error: Cannot create JSON from requestData")
                return
            }
            
            // Create a URL request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Perform the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle the response here
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                    print("Server err: \(response.statusCode)")
                    return
                }
                
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        completion(dataString)
                    }
                }
            }.resume()
        }
}


extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.isRecording = false
        
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }
        
        self.audioPowerData.removeAll()
    }
}
