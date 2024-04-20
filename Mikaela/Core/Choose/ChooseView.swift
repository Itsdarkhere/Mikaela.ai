//
//  ChooseView.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 10.4.2024.
//

import SwiftUI

struct ChooseView: View {
    // Initialize Supabase authentication
    // private var supabaseData: SupabaseData = SupabaseData()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var scenes: [SceneSS] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Choose a scene")
                List {
                    ForEach(scenes, id: \.self) { scene in
                        SceneView(title: scene.title, description: scene.user_instruction)
                    }
                }
                Spacer()
                Button {
                    Task {
                        print("Logging user out...")
                        await authViewModel.signoutUser()
                    }
                } label: {
                    Text("LOGOUT")
                }
            }
            .onAppear {
                Task {
                    scenes = await authViewModel.getScenes()
                }
            }
        }
    }
}

#Preview {
    ChooseView().environmentObject(AuthViewModel())
}
