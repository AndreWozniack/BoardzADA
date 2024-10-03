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
    @Published var players: [Player] = []
    private var db = Firestore.firestore()
    
    // Função para adicionar ou atualizar um jogador no banco de dados Firestore
    func addOrUpdatePlayer(player: Player) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Usuário não está logado.")
            return
        }
        do {
            try await db.collection("players").document(userId).setData(from: player)
            print("Jogador salvo com sucesso!")
        } catch let error {
            print("Erro ao salvar o jogador: \(error.localizedDescription)")
        }
    }
    
    // Função para buscar informações do jogador atual
    func fetchPlayer() async throws -> Player? {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Usuário não está logado.")
            return nil
        }

        let document = try await db.collection("players").document(userId).getDocument()
        if let player = try? document.data(as: Player.self) {
            return player
        } else {
            return nil
        }
    }
    
    // Função para atualizar o status de um jogador jogando ou na fila
    func updatePlayerStatus(playerId: String, isPlaying: Bool, currentGameId: String?, waitingForGameIds: [String]) async {
        do {
            let document = db.collection("players").document(playerId)
            try await document.updateData([
                "isPlaying": isPlaying,
                "currentGameId": currentGameId as Any, // Se o jogador estiver jogando, salva o jogo
                "waitingForGameIds": waitingForGameIds  // Atualiza a lista de espera
            ])
            print("Status do jogador atualizado.")
        } catch let error {
            print("Erro ao atualizar o status do jogador: \(error.localizedDescription)")
        }
    }
    
    // Função para adicionar um jogador à fila de espera de um jogo
    func addPlayerToWaitingList(player: Player, gameId: String) async {
        var updatedPlayer = player
        if !updatedPlayer.waitingForGameIds.contains(gameId) {
            updatedPlayer.waitingForGameIds.append(gameId)
        }
        await addOrUpdatePlayer(player: updatedPlayer)
    }
    
    // Função para remover um jogador da fila de espera
    func removePlayerFromWaitingList(player: Player, gameId: String) async {
        var updatedPlayer = player
        updatedPlayer.waitingForGameIds.removeAll { $0 == gameId }
        await addOrUpdatePlayer(player: updatedPlayer)
    }
    
    // Função para mover o jogador da fila para o status de jogando
    func movePlayerFromWaitingToPlaying(player: Player, gameId: String) async {
        var updatedPlayer = player
        updatedPlayer.isPlaying = true
        updatedPlayer.currentGameId = gameId
        updatedPlayer.waitingForGameIds.removeAll { $0 == gameId }
        await addOrUpdatePlayer(player: updatedPlayer)
    }

    // Função para remover o jogador do jogo
    func removePlayerFromGame(player: Player) async {
        var updatedPlayer = player
        updatedPlayer.isPlaying = false
        updatedPlayer.currentGameId = nil
        await addOrUpdatePlayer(player: updatedPlayer)
    }
}

