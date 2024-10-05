//
//  UserManagaer.swift
//  BordADA
//
//  Created by André Wozniack on 02/10/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserManager: ObservableObject {
    private var db = Firestore.firestore()
    @Published var name = ""
    
    func createPlayer() async {
        guard let user = Auth.auth().currentUser else {
            print("Usuário não está logado.")
            return
        }
        
        let userId = user.uid
        let name = user.displayName ?? "Usuário"
        let email = user.email ?? ""
        
        do {
            let playerRef = db.collection("players").document(userId)
            let document = try await playerRef.getDocument()
            if document.exists {
                print("Jogador já existe. Não é necessário criar.")
                return
            }
            
            let newPlayer = Player(id: userId, name: name, email: email)
            try playerRef.setData(from: newPlayer)
            print("Jogador criado com sucesso!")
        } catch let error {
            print("Erro ao criar o jogador: \(error.localizedDescription)")
        }
    }
    
    func updatePlayer(name: String? = nil, email: String? = nil, isPlaying: Bool? = nil, currentGameId: String? = nil) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Usuário não está logado.")
            return
        }
        do {
            var dataToUpdate: [String: Any] = [:]
            if let name = name {
                dataToUpdate["name"] = name
                self.name = name
            }
            if let email = email {
                dataToUpdate["email"] = email
            }
            if let isPlaying = isPlaying {
                dataToUpdate["isPlaying"] = isPlaying
            }
            if let currentGameId = currentGameId {
                dataToUpdate["currentGameId"] = currentGameId
            }
            if !dataToUpdate.isEmpty {
                let document = db.collection("players").document(userId)
                try await document.updateData(dataToUpdate)
                print("Jogador atualizado com sucesso!")
            } else {
                print("Nenhum dado para atualizar.")
            }
        } catch let error {
            print("Erro ao atualizar o jogador: \(error.localizedDescription)")
        }
    }
    
    func checkIfPlayerExists() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Usuário não está logado.")
            return false
        }
        do {
            let document = try await db.collection("players").document(userId).getDocument()
            return document.exists
        } catch let error {
            print("Erro ao verificar se o jogador existe: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchPlayer() async throws -> Player? {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Usuário não está logado.")
            return nil
        }

        let document = try await db.collection("players").document(userId).getDocument()
        if let player = try? document.data(as: Player.self) {
            self.name = player.name
            return player
        } else {
            return nil
        }
    }
    
    // Função para atualizar o status do jogador
    func updatePlayerStatus(isPlaying: Bool, currentGameId: String?) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Usuário não está logado.")
            return
        }
        do {
            let document = db.collection("players").document(userId)
            try await document.updateData([
                "isPlaying": isPlaying
            ])
            print("Status do jogador atualizado.")
        } catch let error {
            print("Erro ao atualizar o status do jogador: \(error.localizedDescription)")
        }
    }
}


