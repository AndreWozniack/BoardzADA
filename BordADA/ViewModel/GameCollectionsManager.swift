//
//  GameCollectionsManager.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//
import Foundation
import FirebaseFirestore

class GamesCollectionManager: ObservableObject {
    @Published var gameList: [BoardGame] = []
    
    private var db = Firestore.firestore()
    
    func addGame(_ game: BoardGame) async {
        do {
            try db.collection("games").document(game.id).setData(from: game)
            DispatchQueue.main.async {
                self.gameList.append(game)
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
    
    func addNewGame(name: String, owner: String, numPlayersMin: Int, numPlayersMax: Int, description: String) async {
        let newGame = BoardGame(
            name: name,
            owner: owner,
            status: .free,
            difficult: .easy,
            numPlayersMax: numPlayersMax,
            numPlayersMin: numPlayersMin,
            description: description
        )
        await addGame(newGame)
    }

    
    func getAvailableGames() -> [BoardGame] {
        return gameList.filter { $0.status == .free }
    }
}

