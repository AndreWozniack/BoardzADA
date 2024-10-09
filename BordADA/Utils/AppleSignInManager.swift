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

class AppleSignInManager: NSObject, ObservableObject {
    @Published var currentNonce: String?
    
    func startSignInWithAppleFlow(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func handle(authorization: ASAuthorization, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Falha de validação do nonce. Uma nova autenticação foi solicitada sem um nonce.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Erro ao obter o token de identidade do Apple ID.")
                completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao obter token de identidade"])))
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Não foi possível converter o token de identidade em uma string.")
                completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao converter token de identidade"])))
                return
            }

            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: idTokenString,
                rawNonce: nonce
            )

            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Erro ao autenticar com Firebase: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                if let authResult = authResult {
                    Task {
                        let userManager = UserManager.shared

                        // Capturar o nome completo do usuário, se disponível
                        var displayName: String?
                        if let fullName = appleIDCredential.fullName {
                            displayName = [fullName.givenName, fullName.familyName]
                                .compactMap { $0 }
                                .joined(separator: " ")

                            // Atualizar o displayName no Firebase Auth
                            let changeRequest = authResult.user.createProfileChangeRequest()
                            changeRequest.displayName = displayName
                            try await changeRequest.commitChanges()
                        } else {
                            displayName = authResult.user.displayName
                        }

                        if await !userManager.checkIfPlayerExists() {
                            await userManager.createPlayer()
                        }
                        print("Usuário autenticado com sucesso: \(authResult.user.uid)")
                        completion(.success(authResult))
                    }
                }
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
            if status != errSecSuccess {
                fatalError("Não foi possível gerar nonce aleatório. Código de erro: \(status)")
            }

            randomBytes.forEach { randomByte in
                if remainingLength == 0 {
                    return
                }

                // Seleciona um caractere aleatório do charset
                let index = Int(randomByte) % charset.count
                result.append(charset[index])
                remainingLength -= 1
            }
        }

        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        // Converte os bytes hash em uma string hexadecimal
        let hashString = hashedData.map { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
