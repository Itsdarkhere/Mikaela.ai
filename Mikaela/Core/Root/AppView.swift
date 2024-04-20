//
//  AppView.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 13.4.2024.
//

import SwiftUI
import Supabase

struct AppView: View {
    @StateObject var authVM = AuthViewModel()
    var body: some View {
        Group {
            if authVM.isAuthenticated {
                ChooseView().environmentObject(authVM)
            } else {
                LoginView().environmentObject(authVM)
            }
        }
        .task {
            // Look for auth-state change
            await authVM.watchAuthState()
        }
    }
}

#Preview {
    AppView()
}
