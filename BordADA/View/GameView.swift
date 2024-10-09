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

    @State var apiResult: String = ""
    @State var isShowing: Bool = false

    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(game.name)
                    .font(.title)
                    .foregroundStyle(.white)
                    .bold()
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(.purple)

            ScrollView {
                AsyncImage(url: URL(string: game.imageUrl)) { result in
                    switch result {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty:
                        Rectangle()
                            .foregroundStyle(.purple)
                    case .failure(_):
                        Rectangle()
                            .foregroundStyle(.red)
                    @unknown default:
                        Rectangle()
                            .foregroundStyle(.purple)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))

                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")

                    Text(game.owner)

                    Spacer()
                }
                .padding(.top, 8)

                VStack(alignment: .leading) {
                    HStack {
                        Text("Descrição")
                            .font(.title2)
                            .bold()

                        Spacer()
                    }

                    Text(game.description)
                }
                .padding(.top, 8)

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")

                    Text(
                        "\(game.numPlayersMin) - \(game.numPlayersMax) jogadores"
                    )

                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding(24)

            Button(action: { self.isShowing.toggle() }) {
                Text("Entrar no jogo")
            }
        }
        .background(Color.uiBackground)
        .task {
            // Se precisar fazer alguma operação assíncrona com o game
            // Por exemplo, carregar detalhes adicionais
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
