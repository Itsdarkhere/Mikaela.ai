//
//  msgView.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 11.4.2024.
//
import AVFoundation
import Foundation
import SwiftUI

struct msgView: View {
    @State var response: String = "Empty..."
    var body: some View {
        Text(response)
            .padding()
            .foregroundColor(.black)
        Button {
            askForText { message in
               response = message
            }
        } label: {
            Text("Ask for text")
                .foregroundColor(.white)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.red))
        .cornerRadius(8)
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

#Preview {
    msgView()
}
