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
    @State private var duration: Int = 10
    @StateObject var vm = GamesCollectionManager.shared
    
    @EnvironmentObject var router: Router<AppRoute>
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack {
                    HStack(alignment: .top) {
                        Spacer()
                        Text("")
                            .padding()
                            .font(.title)
                            .bold()
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.vertical, 24)
                    .background(Color.clear)
                    .ignoresSafeArea(edges: .top)
                }
                VStack(spacing: 24) {
                    Spacer()
                    Group {
                        HStack(alignment: .top){
                            GameImageView(imageUrl: selectedGame.thumb ?? "")
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
            HStack(alignment: .top) {
                Spacer()
                Text("Adicionar Jogo")
                    .padding()
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.top, 24)
            .padding(.vertical, 24)
            .background(Color.roxo)
            .ignoresSafeArea(edges: .top)
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .padding(.bottom, 700)

        }
        .ignoresSafeArea(.all)
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
                duration: duration,
                waitingPlayers: [],
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
                link: "Link de compra",
                tp_jogo: "Tipo"
            )
        )
    }
}


