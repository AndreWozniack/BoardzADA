//
//  GameCollectionsManager.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//
import Foundation
import FirebaseFirestore

class GamesCollectionManager: ObservableObject {
    
    static let shared = GamesCollectionManager()
    @Published var gameList: [BoardGame] = []
    @Published var freeGames: [BoardGame] = []
    @Published var occupiedGames: [BoardGame] = []

    private var db = Firestore.firestore()
    var listener: ListenerRegistration?
    var gameListeners: [ListenerRegistration] = []
    
    init() {
        startListening()
        for game in gameList {
            print("==============================\nID:\(game.name)\nNome:\(game.id)\n==============================")

        }
    }

    func listenForGameChanges() {
        listener = db.collection("games").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Erro ao escutar mudanças: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                print("Nenhuma mudança detectada.")
                return
            }
            
            let games = snapshot.documents.compactMap { document -> BoardGame? in
                return try? document.data(as: BoardGame.self)
            }

            DispatchQueue.main.async {
                self.gameList = games
                self.updateFilteredLists()
                self.addListenersToGames(games: games)
            }
        }
    }
    
    private func addListenersToGames(games: [BoardGame]) {
        for listener in gameListeners {
            listener.remove()
        }
        gameListeners.removeAll()

        for game in games {
            let gameListener = db.collection("games").document(game.id.uuidString).addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Erro ao escutar mudanças no jogo \(game.name): \(error.localizedDescription)")
                    return
                }

                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                    print("Documento do jogo não encontrado.")
                    return
                }

                if let updatedGame = try? documentSnapshot.data(as: BoardGame.self) {
                    DispatchQueue.main.async {
                        if let index = self.gameList.firstIndex(where: { $0.id == updatedGame.id }) {
                            self.gameList[index] = updatedGame
                            self.updateFilteredLists()
                        }
                    }
                }
            }
            
            gameListeners.append(gameListener)
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
        for listener in gameListeners {
            listener.remove()
        }
        gameListeners.removeAll()
    }
    
    func updateFilteredLists() {
        self.freeGames = self.gameList.filter { $0.status == .free }
        self.occupiedGames = self.gameList.filter { $0.status == .occupied }
    }
    
    func startListening() {
        listenForGameChanges()
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
            
            for game in games {
                print("==============================\nID:\(game.name)\nNome:\(game.id)\n==============================")

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
            waitingPlayerRefs: [],
            imageUrl: imageUrl
        )
        await addGame(newGame)
    }
    
    func getAvailableGames() -> [BoardGame] {
        return gameList.filter { $0.status == .free }
    }
    
    func fetchPlayer(for game: BoardGame, completion: @escaping (Player?) -> Void) {
        guard let playerRef = game.currentPlayerRef else {
            completion(nil)
            return
        }
        
        playerRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let player = try document.data(as: Player.self)
                    completion(player)
                } catch {
                    print("Erro ao decodificar Player: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("Erro ao buscar jogador: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
    
    func fetchPlayer(from reference: DocumentReference, completion: @escaping (Player?) -> Void) {
        reference.getDocument { snapshot, error in
            guard let document = snapshot, document.exists, let player = try? document.data(as: Player.self) else {
                print("Erro ao buscar jogador: \(error?.localizedDescription ?? "Erro desconhecido")")
                completion(nil)
                return
            }
            completion(player)
        }
    }

    
    func addCurrentPlayer(to gameId: String, playerID: String) async {
        let gameRef = db.collection("games").document(gameId)
        let playerRef = db.collection("players").document(playerID)
        
        do {
            let result = try await db.runTransaction { (transaction, errorPointer) -> Any? in
                transaction.updateData([
                    "currentPlayerRef": playerRef,
                    "status": GameStatus.occupied.rawValue
                ], forDocument: gameRef)

                return nil
            }
            print(result ?? "")
            print("Jogador definido como currentPlayer do jogo \(gameId).")
        } catch {
            print("Erro ao adicionar currentPlayer: \(error.localizedDescription)")
        }
    }

    func addPlayerToWaitingList(gameId: String, playerID: String) async {
        let gameRef = db.collection("games").document(gameId)
        let playerRef = db.collection("players").document(playerID)

        do {
            try await gameRef.updateData([
                "waitingPlayerRefs": FieldValue.arrayUnion([playerRef])
            ])
            print("Jogador adicionado à fila do jogo.")
        } catch {
            print("Erro ao adicionar jogador à fila: \(error.localizedDescription)")
        }
    }

    func removePlayerFromWaitingList(gameId: String, playerID: String) async {
        let gameRef = db.collection("games").document(gameId)
        let playerRef = db.collection("players").document(playerID)

        do {
            try await gameRef.updateData([
                "waitingPlayerRefs": FieldValue.arrayRemove([playerRef])
            ])
            print("Jogador removido da fila do jogo.")
        } catch {
            print("Erro ao remover jogador da fila: \(error.localizedDescription)")
        }
    }

    func fetchWaitingPlayers(from references: [DocumentReference], completion: @escaping ([Player]) -> Void) {
        var players: [Player] = []
        let group = DispatchGroup()

        for reference in references {
            group.enter()
            fetchPlayer(from: reference) { player in
                if let player = player {
                    players.append(player)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(players)
        }
    }

    func fetchGamesWithPlayers() async {
        do {
            let snapshot = try await db.collection("games").getDocuments()
            let games = snapshot.documents.compactMap { document -> BoardGame? in
                return try? document.data(as: BoardGame.self)
            }

            DispatchQueue.main.async {
                self.updateFilteredLists()
            }

            for game in games {
                if game.status == .occupied, let currentPlayerRef = game.currentPlayerRef {
                    fetchPlayer(from: currentPlayerRef) { player in
                        if player != nil {
                            DispatchQueue.main.async {
                                self.gameList.append(
                                    BoardGame(
                                        name: game.name,
                                        owner: game.owner,
                                        status: game.status,
                                        difficult: game.difficult,
                                        numPlayersMax: game.numPlayersMax,
                                        numPlayersMin: game.numPlayersMin,
                                        description: game.description,
                                        duration: game.duration,
                                        currentPlayerRef: game.currentPlayerRef,
                                        waitingPlayerRefs: game.waitingPlayerRefs,
                                        imageUrl: game.imageUrl
                                    )
                                )
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
//                        self.freeGames.append(game)
                        self.gameList.append(game)
                    }
                }
            }
        } catch {
            print("Erro ao buscar jogos: \(error.localizedDescription)")
        }
    }

    func removeCurrentPlayer(from gameId: String) async {
        let gameRef = db.collection("games").document(gameId)

        do {
            let result = try await db.runTransaction { (transaction, errorPointer) -> Any? in
                let gameSnapshot: DocumentSnapshot
                do {
                    gameSnapshot = try transaction.getDocument(gameRef)
                } catch {
                    errorPointer?.pointee = NSError(domain: "GameError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Erro ao obter documento do jogo."])
                    return nil
                }
                
                guard let gameData = gameSnapshot.data(),
                      let waitingPlayerRefs = gameData["waitingPlayerRefs"] as? [DocumentReference] else {
                    errorPointer?.pointee = NSError(domain: "GameError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dados do jogo inválidos."])
                    return nil
                }
                
                if !waitingPlayerRefs.isEmpty {
                    let nextPlayerRef = waitingPlayerRefs[0]

                    transaction.updateData([
                        "currentPlayerRef": nextPlayerRef,
                        "waitingPlayerRefs": FieldValue.arrayRemove([nextPlayerRef])
                    ], forDocument: gameRef)
                    
                } else {
                    transaction.updateData([
                        "currentPlayerRef": FieldValue.delete(),
                        "status": GameStatus.free.rawValue
                    ], forDocument: gameRef)
                }
                return nil
            }
            print(result ?? "")
            print("currentPlayer removido e fila atualizada para o jogo \(gameId).")
        } catch {
            print("Erro ao remover currentPlayer: \(error.localizedDescription)")
        }
    }

    func promoteNextPlayer(in game: BoardGame) async {
        let gameId = game.id.uuidString
        await removeCurrentPlayer(from: gameId)
    }
}
