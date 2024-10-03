//
//  GameCreateViewModel.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class GameCreateViewModel: ObservableObject {
    @Published var gameList: [BoardGame] = []
    
    
    private var listener: ListenerRegistration?
    
    func listenToGameUpdates() {
        listener = db.collection("games").addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Erro ao escutar atualizações de jogos: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Nenhum jogo encontrado.")
                return
            }
            
            DispatchQueue.main.async {
                self?.gameList = documents.compactMap { document -> BoardGame? in
                    return try? document.data(as: BoardGame.self)
                }
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    
    func createAndSaveGame(
        name: String,
        owner: String,
        description: String,
        numPlayersMin: Int,
        numPlayersMax: Int,
        status: GameStatus,
        difficult: GameDifficult,
        duration: Int
        imageUrl: String
    ) async throws -> BoardGame {
        let newGame = BoardGame(
            name: name,
            owner: owner,
            status: status,
            difficult: difficult,
            numPlayersMax: numPlayersMax,
            numPlayersMin: numPlayersMin,
            description: description,
            duration: duration
            imageUrl: imageUrl
        )

        await addGame(newGame)
        return newGame
    }
    
    private var db = Firestore.firestore()
    
    func addGame(_ game: BoardGame) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Usuário não está logado.")
            return
        }
        do {
            try db.collection("games").document(game.id).setData(from: game) { error in
                if let error {
                    print("Erro ao salvar jogo: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.gameList.append(game)
                    }
                }
            }
        } catch {
            print("Erro ao salvar jogo: \(error.localizedDescription)")
        }
    }
    
    func fetchGames() async {
        do {
            let snapshot = try await db.collection("games").getDocuments()
            let games = snapshot.documents.compactMap { document -> BoardGame? in
                return try? document.data(as: BoardGame.self)
            }
            DispatchQueue.main.async {
                self.gameList = games
            }
        } catch {
            print("Erro ao buscar jogos: \(error.localizedDescription)")
        }
    }
    
    func updateGame(_ id: String, with changes: (GameManager) -> Void) async {
        if let gameIndex = gameList.firstIndex(where: { $0.id == id }) {
            let gameManager = GameManager(boardGame: gameList[gameIndex])
            changes(gameManager)
            let updatedGame = gameManager.getGame()
            
            do {
                try db.collection("games").document(id).setData(from: updatedGame)
                DispatchQueue.main.async {
                    self.gameList[gameIndex] = updatedGame
                }
            } catch {
                print("Erro ao atualizar jogo: \(error.localizedDescription)")
            }
        }
    }
    
    func removeGame(by id: String) async {
        do {
            try await db.collection("games").document(id).delete()
            DispatchQueue.main.async {
                self.gameList.removeAll { $0.id == id }
            }
        } catch {
            print("Erro ao remover o jogo: \(error.localizedDescription)")
        }
    }
    
    func addNewGame(name: String, owner: String,gameDifficult: GameDifficult, numPlayersMin: Int, numPlayersMax: Int, description: String, duration: Int, imageUrl: String) async {
        let newGame = BoardGame(
            name: name,
            owner: owner,
            status: .free,
            difficult: gameDifficult,
            numPlayersMax: numPlayersMax,
            numPlayersMin: numPlayersMin,
            description: description,
            duration: duration
            imageUrl: imageUrl
        )
        await addGame(newGame)
    }

    
    func getAvailableGames() -> [BoardGame] {
        return gameList.filter { $0.status == .free }
    }
}
