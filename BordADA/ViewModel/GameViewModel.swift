class GameViewModel: ObservableObject {
    @Published var game: BoardGame
    @Published var currentPlayer: Player?
    @Published var waitingPlayers: [Player] = []
    
    init(game: BoardGame) {
        self.game = game
        Task {
            await loadCurrentPlayerAndWaitingList()
        }
    }
    
    @MainActor
    func loadCurrentPlayerAndWaitingList() async {
        if game.status == .occupied {
            self.currentPlayer = await GamesCollectionManager.shared.fetchPlayer(from: game.currentPlayerRef!)
            self.waitingPlayers = await GamesCollectionManager.shared.fetchWaitingPlayers(from: game.waitingPlayerRefs)
        }
    }
    
    func joinGame() async {
        await GamesCollectionManager.shared.addCurrentPlayer(
            to: game.id.uuidString,
            playerID: UserManager.shared.currentUser.id ?? ""
        )
        await MainActor.run {
            self.game.status = .occupied
            self.game.currentPlayerRef = UserManager.shared.currentUser.id
        }
    }
    
    func leaveGame() async {
        await GamesCollectionManager.shared.removeCurrentPlayer(from: game.id.uuidString)
        await MainActor.run {
            self.game.status = .free
            self.game.currentPlayerRef = nil
        }
    }
    
    func joinWaitingList() async {
        await GamesCollectionManager.shared.addPlayerToWaitingList(
            gameId: game.id.uuidString,
            playerID: UserManager.shared.currentUser.id ?? ""
        )
        await MainActor.run {
            self.game.waitingPlayerRefs.append(UserManager.shared.currentUser.id ?? "")
        }
    }
    
    func updateGame() async {
        // Implementar a lógica para atualizar o jogo, se necessário
    }
}
