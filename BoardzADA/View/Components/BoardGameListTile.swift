//
//  BoardGameListTile.swift
//  BordADA
//
//  Created by Felipe Passos on 02/10/24.
//

import SwiftUI

struct BoardGameListTile: View {
    @StateObject var viewModel: BoardGameListTileViewModel
    
    init(game: BoardGame) {
        _viewModel = StateObject(wrappedValue: BoardGameListTileViewModel(game: game))
    }
    
    func getColor() -> Color {
        switch(viewModel.game.status) {
            case .free: return .green
            case .occupied, .reserved: return .red
            case .waiting: return .orange
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            AsyncImage(url: URL(string: viewModel.game.imageUrl)) { result in
                switch result {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    Rectangle()
                        .foregroundStyle(.yellow)
                case .failure(_):
                    Rectangle()
                        .foregroundStyle(.red)
                @unknown default:
                    Rectangle()
                        .foregroundStyle(.purple)
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Rectangle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(viewModel.game.name)
                        .font(.title2)
                        .foregroundStyle(.roxo)
                        .bold()

                    Spacer()

                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(getColor())
                }

                HStack(spacing: 4) {
                    TittleWithText(
                        title: "\(viewModel.game.numPlayersMin) - \(viewModel.game.numPlayersMax) jogadores",
                        sfSymbolTitle: "person.2.fill",
                        titleSize: 12
                    )
                }

                HStack {
                    if let player = viewModel.player {
                        Text(player.name)
                            .foregroundStyle(.uiBackground)
                            .bold()
                            .font(.system(size: 11))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 12)
                            .background(.roxo)
                            .cornerRadius(12, corners: .allCorners)
                    }
                    
                    if !viewModel.game.waitingPlayerRefs.isEmpty {
                        TittleWithText(
                            title: "Fila - \(viewModel.game.waitingPlayerRefs.count)",
                            titleSize: 12
                        )
                    }
                }
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.white)
        .frame(maxWidth: .infinity)
        .clipShape(Rectangle())
        .cornerRadius(12)
    }
}

#Preview {
    VStack {
        BoardGameListTile(
            game: BoardGame(
                name: "Coup",
                owner: "André",
                status: .free,
                difficult: .easy,
                numPlayersMax: 8,
                numPlayersMin: 2,
                description: "",
                duration: 10,
                waitingPlayerRefs: [],
                imageUrl: "https://storage.googleapis.com/ludopedia-capas/35643_t.jpg"
            )
        )
    }
    .padding()
    .background(.red)
}

