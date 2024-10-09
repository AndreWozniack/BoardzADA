//
//  GameCreateView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//  Modiified by André Wozniack 05/10/24
//
import SwiftUI

struct GameCreateView: View {
    @StateObject var vm = GamesCollectionManager()
    @State private var searchName: String = ""
    @State private var searchResults: [LDGame] = []
    @State private var selectedGame: LDGame?
    @State private var owner: String = ""
    @State private var description: String = ""
    @State private var numPlayersMin: Int = 1
    @State private var numPlayersMax: Int = 4
    @State private var status: GameStatus = .free
    @State private var difficult: GameDifficult = .easy
    @State private var errorMessage: String?
    @State private var isSaving: Bool = false
    @State private var duration: Int = 10

    var body: some View {
        ScrollView {
            VStack {
                TextField("Buscar jogo por nome", text: $searchName, onCommit: {
                    Task {
                        await searchGames()
                    }
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

                    Text("Selecione um jogo:")
                        .font(.headline)
                        .padding(.top)

                ForEach(searchResults) { game in
                        Button(action: {
                            selectGame(game)
                        }) {
                            HStack {
                                AsyncImage(url: URL(string: game.thumb ?? ""))
                                Text(game.nm_jogo)
                                    .foregroundColor(.primary)
                                Spacer()
                                if game.id_jogo == selectedGame?.id_jogo {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                

                // Formulário para criar o jogo
                Group {
                    TextField("Nome", text: $searchName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true) // Desabilitado porque o nome vem do jogo selecionado

                    TextField("Responsável", text: $owner)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Descrição", text: $description)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Quantidade mínima de jogadores", value: $numPlayersMin, format: .number)
                        .keyboardType(.numberPad)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Quantidade máxima de jogadores", value: $numPlayersMax, format: .number)
                        .keyboardType(.numberPad)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Picker("Status", selection: $status) {
                        ForEach(GameStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    Picker("Dificuldade", selection: $difficult) {
                        ForEach(GameDifficult.allCases, id: \.self) { difficult in
                            Text(difficult.rawValue.capitalized).tag(difficult)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                if isSaving {
                    ProgressView("Salvando jogo...")
                } else {
                    Button("Criar") {
                        Task {
                            await createGame()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(selectedGame == nil) // Desabilita o botão se nenhum jogo foi selecionado
                }
            }
            .padding()
        }
    }

    func searchGames() async {
        guard !searchName.isEmpty else { return }
        let ludopediaManager = LudopediaManager()
        if let games = await ludopediaManager.buscarJogosPorNome(nome: searchName) {
            print(games.count)
            await MainActor.run {
                self.searchResults = games
            }
        }
    }

    // Função para selecionar um jogo da lista
    func selectGame(_ game: LDGame) {
        self.selectedGame = game
        // Preencher os campos com os dados do jogo selecionado
        self.searchName = game.nm_jogo
        self.description = "" // Pode preencher com algum dado se disponível
        self.numPlayersMin = 1 // Ajuste conforme necessário
        self.numPlayersMax = 4 // Ajuste conforme necessário
        // Você pode preencher outros campos se desejar
    }


    func createGame() async {
        guard let selectedGame = selectedGame else {
            errorMessage = "Por favor, selecione um jogo da lista."
            return
        }
        isSaving = true
        do {
            let game = BoardGame(
                name: selectedGame.nm_jogo,
                owner: owner,
                status: status,
                difficult: difficult,
                numPlayersMax: numPlayersMax,
                numPlayersMin: numPlayersMin,
                description: description,
                duration: duration,
                waitingPlayers: [],
                imageUrl: selectedGame.thumb ?? "no_image"
            )
            await vm.addGame(game)
            print("Jogo criado: \(game)")
            resetFields()
        }
        isSaving = false
    }

    // Reseta os campos do formulário após o jogo ser criado
    func resetFields() {
        searchName = ""
        owner = ""
        description = ""
        numPlayersMin = 1
        numPlayersMax = 4
        status = .free
        difficult = .easy
        errorMessage = nil
        selectedGame = nil
        searchResults = []
    }
}

#Preview {
    GameCreateView()
}

