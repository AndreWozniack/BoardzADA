//
//  SingIn.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//

import Foundation
import SwiftUI
import RouterKit
import _AuthenticationServices_SwiftUI

struct SignInView: View {
    @StateObject var signInManager = AppleSignInManager()
    @EnvironmentObject var router: Router<AppRoute>
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Autenticando...")
            } else {
                Text("Faça login com Apple")
                    .font(.title)
                    .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { _ in },
                    onCompletion: { _ in }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(width: 280, height: 45)
                .padding()
                .onTapGesture {
                    isLoading = true
                    signInManager.startSignInWithAppleFlow { result in
                        isLoading = false
                        switch result {
                        case .success(let authResult):
                            // Navegar ou executar outra ação após o sucesso
                            print("Login bem-sucedido: \(authResult.user.uid)")
                            router.push(to: .gameList)
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }
}

