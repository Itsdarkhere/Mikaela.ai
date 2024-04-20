//
//  AuthViewModel.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 12.4.2024.
//

import Foundation
import Combine
import Supabase

// Define authentication states
enum AuthState: Hashable {
    case Initial
    case Signin
    case Signout
}

struct SceneSS: Decodable, Hashable {
    let scene_prompt: String
    let user_instruction: String
    let title: String
}

class AuthViewModel: ObservableObject {
    // Published properties for SwiftUI views
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var authState: AuthState = AuthState.Initial
    @Published var isLoading = false
    @Published var isAuthenticated = false
    
    // Cancellable set to manage Combine subscriptions
    var cancellable = Set<AnyCancellable>()
    
    // Initialize Supabase authentication
    private var supabaseAuth: SupabaseAuth = SupabaseAuth()
    
    func watchAuthState() async {
        for await state in supabaseAuth.client.auth.authStateChanges {
            if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                await MainActor.run {
                    self.isAuthenticated = state.session != nil
                }
            }
        }
    }
    
    func getScenes() async -> [SceneSS] {
        print("Get scenes...")
        do {
            let scenes: [SceneSS] = try await supabaseAuth.client
              .from("scenes")
              .select("scene_prompt, user_instruction, title")
              .execute()
              .value
            
            return scenes
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    // Check if the user is signed in
    @MainActor
    func isUserSignIn() async {
        do {
            try await supabaseAuth.LoginUser()
            self.authState = AuthState.Signin
        } catch _ {
            self.authState = AuthState.Signout
        }
    }
    
    // Sign up a new user
    @MainActor
    func signUp(email: String, password: String) async {
        do {
            isLoading = true
            try await supabaseAuth.SignUp(email: email, password: password)
            authState = AuthState.Signin
            isLoading = false
        } catch let error {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // Sign in a user
    @MainActor
    func signIn(email: String, password: String) async {
        do {
            isLoading = true
            try await supabaseAuth.SignIn(email: email, password: password)
            authState = AuthState.Signin
            isLoading = false
        } catch let error {
            errorMessage = error.localizedDescription
            isLoading = false
        }
        
        print("STATE: \(authState)")
    }
    
    // Validate email using a regular expression
    func validEmail() -> Bool {
       let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
       let isEmailValid = self.email.range(of: emailRegex, options: .regularExpression) != nil
       return isEmailValid
    }
    
    // Validate password using a regular expression
    func validPassword() -> Bool {
       let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*\\.).{8,}$"
        let isPasswordValid = self.password.range(of: passwordRegex, options: .regularExpression) != nil
       return isPasswordValid
    }
    
    // Sign out a user
    @MainActor
    func signoutUser() async {
        do {
            try await supabaseAuth.signOut()
            authState = AuthState.Signout
        } catch let error {
            errorMessage = error.localizedDescription
        }
    }
}
