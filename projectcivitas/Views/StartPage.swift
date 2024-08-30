//
//  StartPage.swift
//

import Foundation
import SwiftUI

struct StartPage: View {
    @Binding var isUserLoggedIn: Bool
    
    @State private var showSignUp = false
    @State private var showLogin = false
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            Color.oldGloryBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                Text("🇺🇸")
                    .font(.system(size: 100))
                
                Text("Welcome to CivRef")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text("Your centralized platform for democratic engagement")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .modifier(LoginTextFieldStyle())
                    
                    SecureField("Password", text: $password)
                        .modifier(LoginTextFieldStyle())
                    
                    
                    Button(action: { isUserLoggedIn = true; showLogin = true }) {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.oldGloryRed)
                            .cornerRadius(10)
                    }
                    Button(action: { showSignUp = true }) {
                        Text("Don't have an account? Sign up!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.clear)
                    }
                }
                    .padding(.horizontal)
                    .padding(.top, 20)
                Spacer()
                Spacer()
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(isUserLoggedIn: $isUserLoggedIn)
        }
        .sheet(isPresented: $showLogin) {
            ProgressView()
        }
    }



    struct LoginTextFieldStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.oldGloryBlue.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    struct SignUpView: View {
        @Environment(\.presentationMode) var presentationMode
        @Binding var isUserLoggedIn: Bool
        
        @State private var email = ""
        @State private var password = ""
        @State private var confirmPassword = ""
        @State private var fullName = ""
        @State private var errorMessage = ""
        @State private var isLoading = false
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("Full Name", text: $fullName)
                            .autocapitalization(.words)
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    Section(header: Text("Security")) {
                        SecureField("Password", text: $password)
                        SecureField("Confirm Password", text: $confirmPassword)
                    }
                    
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.oldGloryRed)
                        }
                    }
                    
                    Section {
                        Button(action: signUp) {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Sign Up")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .disabled(isLoading || !isFormValid)
                    }
                    
                    
                    Text("By signing up, you agree to our Terms of Service and Privacy Policy.")
                        .font(.caption)
                        .foregroundColor(.oldGloryBlue.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .navigationTitle("Create Account")
                .navigationBarItems(leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
        
        private var isFormValid: Bool {
            !fullName.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
        }
        
        private func signUp() {
            isLoading = true
            errorMessage = ""
            
            // Simulate a successful sign up request
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
                isUserLoggedIn = true
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
