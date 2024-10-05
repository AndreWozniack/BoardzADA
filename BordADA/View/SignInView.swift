//
//  SignInView.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import RouterKit

struct SignInView: View {
    @StateObject var signInManager = AppleSignInManager()
    @StateObject var userManager = UserManager()
    
    @EnvironmentObject var router: Router<AppRoute>
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Autenticando...")
            } else {
                VStack {
                    Text("BoardzADA")
                        .font(.title)
                        .fontDesign(.rounded)
                        .bold()
                        .padding()
                    Image("boardzada")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        signInManager.startSignInWithAppleFlow(request: request)
                    },
                    onCompletion: { result in
                        handleAuthorization(result: result)
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(width: 280, height: 45)
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.roxo)
    }
    
    private func handleAuthorization(result: Result<ASAuthorization, Error>) {
        isLoading = true
        switch result {
        case .success(let authorization):
            signInManager.handle(authorization: authorization) { firebaseResult in
                isLoading = false
                switch firebaseResult {
                case .success(let authResult):
                    Task {
                        let playerExists = await userManager.checkIfPlayerExists()
                        if !playerExists {
                            await userManager.createPlayer()
                        }
                        router.push(to: .gameList)
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        case .failure(let error):
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SignInView()
}
