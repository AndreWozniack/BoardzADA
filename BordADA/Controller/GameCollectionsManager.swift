//
//  GameCollectionsManager.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//

import Foundation
import FirebaseFirestore

class GamesCollectionManager: ObservableObject {
    @Published var games: [BoardGame] = []
    
    private var db = Firestore.firestore()
    func addGame(_ game: BoardGame) {
        do {
            let _ = try db.collection("games").document(game.id).setData(from: game)
            games.append(game)
        } catch {
            print("Erro ao salvar jogo: \(error.localizedDescription)")
        }
    }
    func fetchGames() {
        db.collection("games").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Nenhum documento encontrado")
                return
            }
            
            self.games = documents.compactMap { (queryDocumentSnapshot) -> BoardGame? in
                return try? queryDocumentSnapshot.data(as: BoardGame.self)
            }
        }
    }
    
    func updateGame(_ id: String, with changes: (GameManager) -> Void) {
        if let gameIndex = games.firstIndex(where: { $0.id == id }) {
            let gameManager = GameManager(boardGame: games[gameIndex])
            changes(gameManager)
            games[gameIndex] = gameManager.getGame()
            
            do {
                let _ = try db.collection("games").document(id).setData(from: games[gameIndex])
            } catch {
                print("Erro ao atualizar jogo: \(error.localizedDescription)")
            }
        }
    }
    
    func removeGame(by id: String) {
        db.collection("games").document(id).delete { error in
            if let error = error {
                print("Erro ao remover o jogo: \(error.localizedDescription)")
            } else {
                self.games.removeAll { $0.id == id }
            }
        }
    }
    func getAvailableGames() -> [BoardGame] {
        return games.filter { $0.status == .free }
    }

}
