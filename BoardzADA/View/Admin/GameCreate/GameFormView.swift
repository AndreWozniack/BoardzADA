//
//  GameFormView.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI
import RouterKit

struct GameFormView: View {
    var selectedGame: LDGame
    @State private var name: String = ""
    @State private var owner: String = ""
    @State private var description: String = ""
    @State private var numPlayersMin: Int?
    @State private var numPlayersMax: Int?
    @State private var status: GameStatus = .free
    @State private var difficult: GameDifficult = .easy
    @State private var errorMessage: String?
    @State private var isSaving: Bool = false
    @State private var duration: Int?
    @StateObject var vm = GamesCollectionManager.shared
    
    @EnvironmentObject var router: Router<AppRoute>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Group {
                    HStack(alignment: .top){
                        AsyncImage(url: URL(string: selectedGame.thumb ?? "")) { result in
                            switch result {
                            case .success(let image):
                                image
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .scaledToFit()
                            case .empty, .failure(_):
                                Rectangle()
                                    .frame(width: 150, height: 150)
                                    .foregroundStyle(.purple)
                            @unknown default:
                                Rectangle()
                                    .frame(width: 150, height: 150)
                                    .foregroundStyle(.purple)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack{
                            FormTextField(title: "Nome", text: $name)
                                .onAppear {
                                    name = selectedGame.nm_jogo
                                }
                        }
                    }
                    
                    FormTextField(title: "Responsável", sfSymbol: "checkmark.seal.fill", text: $owner)
                    
                    FormTextField(title: "Descrição", text: $description, isMultiline: true)
                    
                    
                    HStack {
                        FormNumberField(title: "Jogadores", sfSymbol: "person.2.fill", inText: "Mínimo", value: $numPlayersMin)
                        FormNumberField(title: " ", inText: "Máximo", value: $numPlayersMax)
                    }
                    
                    FormNumberField(title: "Duração", inText: "Duração", value: $duration)
                    
                    VStack(alignment: .leading) {
                        Text("Dificuldade")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.roxo)
                        Picker("Dificuldade", selection: $difficult) {
                            ForEach(GameDifficult.allCases, id: \.self) { difficult in
                                Text(difficult.rawValue.capitalized).tag(difficult)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if isSaving {
                    ProgressView("Salvando jogo...")
                } else {
                    DefaultButton(action: {
                        Task {
                            await createGame()
                        }
                    }, text: "Adicionar")
                }
            }
            .padding()
        }
        .background(Color.uiBackground.ignoresSafeArea())
    }

    func createGame() async {
        isSaving = true
        do {
            let game = BoardGame(
                name: selectedGame.nm_jogo,
                owner: owner,
                status: status,
                difficult: difficult,
                numPlayersMax: numPlayersMax ?? 1,
                numPlayersMin: numPlayersMin ?? 4,
                description: description,
                duration: duration ?? 10,
                waitingPlayerRefs: [],
                imageUrl: selectedGame.thumb ?? "no_image"
            )
            await vm.addGame(game)
            print("Jogo criado: \(game)")
            router.push(to: .gameList)
        }
        isSaving = false
    }
}

#Preview {
    NavigationStack {
        GameFormView(
            selectedGame: LDGame(
                id_jogo: 1,
                nm_jogo: "Quest",
                nm_original: "Quest",
                thumb: "https://storage.googleapis.com/ludopedia-capas/35643_t.jpg",
                link: "Link de compra"
            )
        )
    }
}


