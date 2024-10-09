//
//  GameView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @EnvironmentObject var router: Router<AppRoute>
    @State private var isShowing: Bool = false
    @State private var showSuccess = false
    @State private var showError = false

    init(game: BoardGame) {
        _viewModel = StateObject(wrappedValue: GameViewModel(game: game))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading){
                        HStack(alignment: .top, spacing: 8){
                            gameImageView
                            VStack(alignment: .leading, spacing: 16){
                                TittleWithText(title: "Nome", text: viewModel.game.name)
                                TittleWithText(title: "Dono", titleSize: 17, text: viewModel.game.owner, textSize: 13)
                            }
                        }
                        VStack(alignment:.leading, spacing: 32) {
                            TittleWithText(title: "Descrição", text: viewModel.game.description, isMultiline: true)
                            TittleWithText(title: "Jogadores", sfSymbolTitle: "person.2.fill", text: "\(viewModel.game.numPlayersMin) - \(viewModel.game.numPlayersMax)")
                            TittleWithText(title: "Dificuldade", sfSymbolTitle: "chart.bar.fill", text: viewModel.game.difficult.text)
                            
                                GameQueueView(currentPlayer: viewModel.currentPlayer, waitingPlayers: viewModel.waitingPlayers)
                            
                            VStack(alignment: .center){
                                switch viewModel.game.status {
                                case .occupied:
                                    if viewModel.currentPlayer?.id == UserManager.shared.currentUser!.id {
                                        DefaultButton(
                                            action: {
                                                Task {
                                                    await viewModel.leaveGame()
                                                    router.pop()
                                                }
                                            },
                                            text: "Sair do jogo",
                                            isDestructive: true)
                                        
                                    } else if !viewModel.waitingPlayers.contains(
                                        where: { $0.id == UserManager.shared.currentUser!.id
                                        }) {
                                        DefaultButton(
                                            action: {
                                                Task {
                                                    await viewModel.joinWaitingList()
                                                    print("Você foi adicionado à lista de espera")
                                                }
                                            },
                                            text: "Entrar na fila")
                                    } else {
                                        Text("Jogador já está jogando ou na fila!")
                                    }
                                case .free:
                                    DefaultButton(
                                        action: { self.isShowing.toggle()
                                        },
                                        text: "Entrar no jogo")
                                default:
                                    EmptyView()
                                }
                            }
                        }
                        
                    }
                    .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .refreshable {
            viewModel.loadCurrentPlayerAndWaitingList()
        }
        .defaultNavigationAppearence()
        .toolbarTitleDisplayMode(.inlineLarge)
        .navigationTitle(viewModel.game.name)
        .background(Color.uiBackground.ignoresSafeArea())
        .sheet(isPresented: $isShowing) {
            ScannerView(isShowing: $isShowing) { value in
                Task {
                    await handleQRCodeScan(value)
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSuccess) {
            SuccessView(isShowing: $showSuccess)
        }
        .sheet(isPresented: $showError) {
            ErrorView(isShowing: $showError)
        }
    }
    
    private var gameImageView: some View {
        AsyncImage(url: URL(string: viewModel.game.imageUrl)) { result in
            switch result {
            case .success(let image):
                image
                    .resizable()
                    .frame(width: 174, height: 174)
                    .scaledToFit()
            case .empty, .failure(_):
                Rectangle()
                    .frame(width: 174, height: 174)
                    .foregroundStyle(.purple)
            @unknown default:
                Rectangle()
                    .frame(width: 174, height: 174)
                    .foregroundStyle(.purple)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func handleQRCodeScan(_ qrCode: String) async {
        if qrCode == viewModel.game.id.uuidString {
            await viewModel.joinGame()
            showSuccess = true
        } else {
            print("Jogo não encontrado.")
            showError = true
        }
    }
}


#Preview {
    GameView(
        game: BoardGame(
            name: "Quest",
            owner: "Felipe",
            status: .occupied,
            difficult: .easy,
            numPlayersMax: 5,
            numPlayersMin: 3,
            description: "É um jogo mt foda aaaaaaaa",
            duration: 5,
            waitingPlayerRefs: [],
            imageUrl: ""
        )
    )
}
