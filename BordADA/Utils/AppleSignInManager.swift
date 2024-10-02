//
//  AppleSignInManager.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import SwiftUI

class AppleSignInManager: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @Published var currentNonce: String?

    // Função para iniciar o login com Apple com um completion handler
    func startSignInWithAppleFlow(completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let nonce = randomNonceString()
        currentNonce = nonce
        let request = createAppleIDRequest(with: nonce)
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        self.completionHandler = completion
        authController.performRequests()
    }

    private var completionHandler: ((Result<AuthDataResult, Error>) -> Void)?

    // Criação do pedido de login com Apple
    private func createAppleIDRequest(with nonce: String) -> ASAuthorizationAppleIDRequest {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
    }

    // Função auxiliar para gerar um nonce aleatório (necessário para segurança)
    private func randomNonceString(length: Int = 32) -> String {
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Não foi possível gerar nonce aleatório")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    // Função auxiliar para realizar o hash SHA256 da nonce
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }

    // Callback do ASAuthorizationController para autenticação bem-sucedida
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Erro ao obter as credenciais do Apple ID")
            self.completionHandler?(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao obter credenciais"])))
            return
        }

        guard let nonce = currentNonce else {
            fatalError("Falha de validação do nonce. Uma nova autenticação foi solicitada sem um nonce.")
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Erro ao obter o token de identidade do Apple ID.")
            self.completionHandler?(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao obter token de identidade"])))
            return
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Não foi possível converter o token de identidade em uma string.")
            self.completionHandler?(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao converter token de identidade"])))
            return
        }

        // Configurar credenciais Firebase com o token de identidade
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

        // Autenticar no Firebase
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Erro ao autenticar com Firebase: \(error.localizedDescription)")
                self.completionHandler?(.failure(error))
                return
            }

            if let authResult = authResult {
                // Autenticação bem-sucedida
                print("Usuário autenticado com sucesso: \(authResult.user.uid)")
                self.completionHandler?(.success(authResult))
            }
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
}
