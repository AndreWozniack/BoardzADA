//
//  GameView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI

struct GameView: View {
    var id: String

    @State var apiResult: String = ""
    @State var isShowing: Bool = false

    @EnvironmentObject var router: Router<AppRoute>

    // TODO: Remover mock
    @State var game: BoardGame = BoardGame(
        name: "Quest", owner: "Felipe", status: .free,
        difficult: .easy, numPlayersMax: 10, numPlayersMin: 4,
        description:
            "Quest é um jogo mt bom para jogar com amigos, bla bla bla",
        imageUrl:
            "https://storage.googleapis.com/ludopedia-capas/35643_t.jpg"
    )

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
                    @unknown default:
                        Rectangle()
                            .foregroundStyle(.purple)
                    }
                }
                .clipShape(.rect(cornerRadius: 12))

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

            let result = await LudopediaManager().jogo(id: 1)

            apiResult = result.debugDescription
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
    GameView(id: "1234")
}
