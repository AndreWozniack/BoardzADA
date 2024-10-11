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
                        HStack(alignment: .top, spacing: 8) {
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
                            VStack(alignment: .leading, spacing: 16) {
                                TittleWithText(title: "Nome", text: viewModel.game.name)
                                TittleWithText(title: "Dono", titleSize: 17, text: viewModel.game.owner, textSize: 13)
                            }
                        }
                        VStack(alignment:.leading, spacing: 32) {
                            
                            TittleWithText(
                                title: "Descrição",
                                text: viewModel.game.description,
                                isMultiline: true
                            )
                            
                            TittleWithText(
                                title: "Jogadores",
                                sfSymbolTitle: "person.2.fill",
                                text: "\(viewModel.game.numPlayersMin) - \(viewModel.game.numPlayersMax)"
                            )
                            
                            TittleWithText(
                                title: "Dificuldade",
                                sfSymbolTitle: "chart.bar.fill",
                                text: viewModel.game.difficult.text
                            )
                            
                            TittleWithText(
                                title: "Duração",
                                sfSymbolTitle: "gauge.with.needle.fill",
                                text: "\(viewModel.game.duration) min"
                            )
                            
                            VStack(alignment: .center){
                                switch viewModel.game.status {
                                case .occupied:
                                    GameQueueView(
                                        currentPlayer: viewModel.currentPlayer,
                                        waitingPlayers: viewModel.waitingPlayers
                                    )
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
                                                }
                                            },
                                            text: "Entrar na fila")
                                        
                                    } else {

                                        DefaultButton(
                                            action: {
                                            },
                                            text: "Jogador já entrou na fila",
                                            isDestructive: true)
                                            .disabled(true)
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(viewModel.game.name)
                        .font(.largeTitle)
                        .foregroundStyle(.uiBackground)
                        .bold()
                        
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(getColor(for: viewModel.game.status))
                }
                .padding(.top, 8)
            }
        }
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
    
    private func handleQRCodeScan(_ qrCode: String) async {
        if qrCode == viewModel.game.id.uuidString {
            await viewModel.joinGame()
            viewModel.loadCurrentPlayerAndWaitingList()
            showSuccess = true
        } else {
            print("Jogo não encontrado.")
            showError = true
        }
    }
    
    private func getColor(for status: GameStatus) -> Color {
        switch status {
        case .free: return .green
        case .occupied, .reserved: return .red
        case .waiting: return .orange
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
