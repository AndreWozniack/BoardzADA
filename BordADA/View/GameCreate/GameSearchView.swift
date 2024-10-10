//
//  GameSearchView.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI
import RouterKit

struct GameSearchView: View {
    @State private var searchName: String = "Catan"
    @State private var searchResults: [LDGame] = []
    @State private var selectedGame: LDGame?
    @StateObject var vm = GamesCollectionManager.shared
    
    @EnvironmentObject var router: Router<AppRoute>

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            FormTextField(title: "Buscar jogo:", text: $searchName, onSubmitAction: {
                Task {
                    await searchGames()
                }
            })
            Text("Selecione um jogo:")
                .font(.headline)
                .padding(.top)
                .background(Color.uiBackground)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(searchResults) { game in
                    Button(action: { router.push(to: .gameForm(game)) }) {
                        SimpleGameTile(imageUrl: game.thumb!, name: game.nm_jogo)
                    }
                }
            }
            .padding(.horizontal)
            
            if searchResults.isEmpty {
                DefaultButton(
                    action: {
                        router.push(
                            to: .gameForm(
                                LDGame(
                                    id_jogo: 0,
                                    nm_jogo: "",
                                    nm_original: "",
                                    thumb: nil,
                                    link: nil,
                                    tp_jogo: nil
                                )
                            )
                        )
                    },
                    text: "Não encontrei meu jogo")
            }
            Spacer()
        }
        .padding()
        .ignoresSafeArea([.keyboard, .container])
        .background(Color.uiBackground)
        
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
}

#Preview {
    NavigationStack {
        GameSearchView()
    }
}
