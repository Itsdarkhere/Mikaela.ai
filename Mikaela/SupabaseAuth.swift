//
//  Supabase.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 12.4.2024.
//

import Foundation
import Supabase

// Taken from a beautiful blog post at:
// https://medium.com/@sarimk80/seamless-authentication-with-swiftui-supabase-113915f154ab
class SupabaseAuth {
    // supabaseKey -> anon key -> safe client side ( bcs row level security )
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://obxdnzcuxovpyzmclucf.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ieGRuemN1eG92cHl6bWNsdWNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTIxNTE2NDUsImV4cCI6MjAyNzcyNzY0NX0.ctNPxvYWx3IHKK-D4fmQVaXx0oIn3MfU3lo02wk-Nrc"
    )
    
    // Checks user login-state
    func LoginUser() async throws {
        do {
            let _ = try await client.auth.session
        } catch let error{
            throw error
        }
    }
    
    func SignIn(email:String,password:String) async throws {
        do {
            try await client.auth.signIn(email: email.lowercased(), password: password)
        } catch let error{
            throw error
        }
    }
    
    
    func SignUp(email:String,password:String) async throws{
        do {
            try await client.auth.signUp(email: email.lowercased(), password: password)
        } catch let error{
            throw error
        }
    }
    
    func signOut() async throws{
        do {
            try await client.auth.signOut()
        } catch let error{
            throw error
        }
    }
}
