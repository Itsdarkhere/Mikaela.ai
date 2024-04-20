//
//  LoginView.swift
//  LearnLoveApp
//
//  Created by Valtteri Juvonen on 10.4.2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = "valtteri.juvone@hotmail.com"
    @State private var password = "tievaes5!"
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Sign in button
                Button {
                    print("Log user in...")
                    Task {
                        await authViewModel.signIn(email: email, password: password)
                    }

                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(
                        width: UIScreen.main.bounds.width - 32,
                        height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(8)
                .padding(.top, 24)
                
                Spacer()
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up!")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    }
                    .font(.system(size: 14))
                }
            }
        }
    }
    
}

#Preview {
    LoginView().environmentObject(AuthViewModel())
}
