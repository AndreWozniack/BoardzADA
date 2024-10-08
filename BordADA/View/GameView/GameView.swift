//
//  GameView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI

struct GameView: View {
    var game: BoardGame

    @State private var apiResult: String = ""
    @State private var isShowing: Bool = false

    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            GameHeaderView(gameName: game.name)
            
            ScrollView {
                GameImageView(imageUrl: game.imageUrl)
                
                GameInfoSection(title: "Dono", text: game.owner, systemImage: "checkmark.seal.fill")

                GameDescriptionSection(description: game.description)

                GameInfoSection(title: "Jogadores", text: "\(game.numPlayersMin) - \(game.numPlayersMax) jogadores", systemImage: "person.2.fill")
            }
            .padding(24)
            
            DefaultButton(action: {self.isShowing.toggle()}, text: "Entrar no jogo")
        }
        .background(Color.uiBackground)
        .task {
            // Aqui você pode fazer operações assíncronas se precisar
        }
        .sheet(isPresented: $isShowing) {
            ScannerView(isShowing: $isShowing) { value in
                router.popToRoot()
                router.push(to: .status(value))
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    GameView(
        game:
            BoardGame(
                name: "Quest",
                owner: "Felipe",
                status: .free,
                difficult: .easy,
                numPlayersMax: 5,
                numPlayersMin: 3,
                description: "É um jogo mt foda aaaaaaaa",
                duration: 5,
                waitingPlayers: [],
                imageUrl: ""
            )
    )
}
