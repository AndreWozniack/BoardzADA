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
    @StateObject var userManager = UserManager.shared
    
    @EnvironmentObject var router: Router<AppRoute>
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var foundPlayer: Bool = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
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
        .onAppear {
            Task {
                await checkForExistingPlayer()
            }
        }
        
    }
    
    private func checkForExistingPlayer() async {
        isLoading = true
        if let player = await userManager.fetchPlayer() {
            router.push(to: .gameList)
        } else {
            isLoading = false
        }
    }
    private func handleAuthorization(result: Result<ASAuthorization, Error>) {
        isLoading = true
        switch result {
        case .success(let authorization):
            signInManager.handle(authorization: authorization) { firebaseResult in
                isLoading = false
                switch firebaseResult {
                case .success(_):
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
