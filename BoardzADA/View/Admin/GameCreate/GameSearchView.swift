//
//  GameSearchView.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI
import RouterKit

struct GameSearchView: View {
    @State private var searchName: String = ""
    @State private var searchResults: [LDGame] = []
    @State private var selectedGame: LDGame?
    @State private var isLoading: Bool = false
    @StateObject var vm = GamesCollectionManager.shared
    
    @EnvironmentObject var router: Router<AppRoute>

    let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12){
                FormTextField(title: "Buscar jogo:", text: $searchName, onSubmitAction: {
                    Task {
                        await searchGames()
                    }
                })
                TittleWithText(title: "Selecione um jogo:")
                
            }
            if isLoading {
                ProgressView("Carregando...")
                    .padding()
                    
            } else {
                                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(searchResults) { game in
                        Button(action: { router.push(to: .gameForm(game)) }) {
                            SimpleGameTile(imageUrl: game.thumb!, name: game.nm_jogo)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            if searchResults.isEmpty && !isLoading {
                DefaultButton(
                    action: {
                        router.push(
                            to: .gameForm(
                                LDGame(
                                    id_jogo: 0,
                                    nm_jogo: "",
                                    nm_original: "",
                                    thumb: nil,
                                    link: nil
                                )
                            )
                        )
                    },
                    text: "Não encontrei meu jogo")
            }
            Spacer()
        }
        .onAppear(perform: {
            Task {
                await initiateGames()
            }
        })
        .padding()
        
    }

    func searchGames() async {
        isLoading = true
        let ludopediaManager = LudopediaManager()
        guard !searchName.isEmpty else {
            return
        }
        
        if let games = await ludopediaManager.buscarJogosPorNome(nome: searchName) {
            print(games.count)
            await MainActor.run {
                self.searchResults = games
                isLoading = false
            }
        }
    }
    
    func initiateGames() async {
        isLoading = true
        let ludopediaManager = LudopediaManager()
        
        if let games = await ludopediaManager.jogos()?.jogos {
            await MainActor.run {
                self.searchResults = games
                isLoading = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        GameSearchView()
    }
}
