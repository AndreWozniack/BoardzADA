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

    func addCurrentPlayer(to gameId: String, playerId: String) async {
        let gameRef = db.collection("games").document(gameId)
        let playerRef = db.collection("players").document(playerId)

        do {
            let result = try await db.runTransaction { (transaction, errorPointer) -> Any? in
                transaction.updateData([
                    "currentPlayer": playerRef,
                    "status": GameStatus.occupied.rawValue
                ], forDocument: gameRef)
                if let error = errorPointer?.pointee {
                    print(error)
                    return nil
                }

                transaction.updateData([
                    "isPlaying": true,
                ], forDocument: playerRef)

                if let error = errorPointer?.pointee {
                    print(error)
                    return nil
                }
                return nil
            }
            print(result ?? "")
            print("Jogador definido como currentPlayer do jogo \(gameId).")
        } catch {
            print("Erro ao adicionar currentPlayer: \(error.localizedDescription)")
        }
    }
    
    func removeCurrentPlayer(from gameId: String, playerId: String) async {
        let gameRef = db.collection("games").document(gameId)
        let playerRef = db.collection("players").document(playerId)

        do {
            let result = try await db.runTransaction { (transaction, errorPointer) -> Any? in
                transaction.updateData([
                    "currentPlayer": FieldValue.delete(),
                    "status": GameStatus.free.rawValue
                ], forDocument: gameRef)
                
                if let error = errorPointer?.pointee {
                    print(error)
                    return nil
                }

                transaction.updateData([
                    "isPlaying": false,
                ], forDocument: playerRef)
                
                if let error = errorPointer?.pointee {
                    print(error)
                    return nil
                }

                return nil
            }
            print(result ?? "")
            print("currentPlayer removido do jogo \(gameId).")
        } catch {
            print("Erro ao remover currentPlayer: \(error.localizedDescription)")
        }
    }

    func addPlayerToWaitingList(gameId: String, playerId: String) async {
        let gameRef = db.collection("games").document(gameId)
        let playerRef = db.collection("players").document(playerId)

        do {
            try await gameRef.updateData([
                "waitingPlayers": FieldValue.arrayUnion([playerRef])
            ])
            print("Jogador \(playerId) adicionado à lista de espera do jogo \(gameId).")
        } catch {
            print("Erro ao adicionar jogador à lista de espera: \(error.localizedDescription)")
        }
    }

    func removePlayerFromWaitingList(gameId: String, playerId: String) async {
        let gameRef = db.collection("games").document(gameId)
        let playerRef = db.collection("players").document(playerId)

        do {
            try await gameRef.updateData([
                "waitingPlayers": FieldValue.arrayRemove([playerRef])
            ])
            print("Jogador \(playerId) removido da lista de espera do jogo \(gameId).")
        } catch {
            print("Erro ao remover jogador da lista de espera: \(error.localizedDescription)")
        }
    }
    
    func addGame(_ game: BoardGame) async {
        do {            
            try db.collection("games").document(game.id.uuidString).setData(from: game)
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
        if let gameIndex = gameList.firstIndex(where: { $0.id.uuidString == id }) {
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
                self.gameList.removeAll { $0.id.uuidString == id }
            }
        } catch {
            print("Erro ao remover o jogo: \(error.localizedDescription)")
        }
    }
    
    func addNewGame(name: String, owner: String, numPlayersMin: Int, numPlayersMax: Int, description: String, duration: Int, imageUrl: String) async {
        let newGame = BoardGame(
            name: name,
            owner: owner,
            status: .free,
            difficult: .easy,
            numPlayersMax: numPlayersMax,
            numPlayersMin: numPlayersMin,
            description: description,
            duration: duration,
            waitingPlayers: [],
            imageUrl: imageUrl
        )
        await addGame(newGame)
    }

    
    func getAvailableGames() -> [BoardGame] {
        return gameList.filter { $0.status == .free }
    }
}

