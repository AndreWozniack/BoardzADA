//
//  AdminGameView.swift
//  BoardzADA
//
//  Created by André Wozniack on 12/10/24.
//


import SwiftUI
import RouterKit

struct AdminGameView: View {
    @StateObject var viewModel: GameViewModel
    @EnvironmentObject var router: Router<AppRoute>
    @State private var isShowing: Bool = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var isEditing = false
    @State private var numPlayersMin: Int?
    @State private var numPlayersMax: Int?
    @State private var duration: Int?

    init(game: BoardGame) {
        _viewModel = StateObject(wrappedValue: GameViewModel(game: game))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading) {
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
                                if isEditing {
                                    FormTextField(title: "Nome do jogo", text: $viewModel.game.name)
                                    FormTextField(title: "Dono", text: $viewModel.game.owner)
                                } else {
                                    TittleWithText(title: "Nome", text: viewModel.game.name)
                                    TittleWithText(title: "Dono", titleSize: 17, text: viewModel.game.owner, textSize: 13)
                                }
                            }
                        }
                        
                        VStack(alignment:.leading, spacing: 32) {
                            if isEditing {
                                FormTextField(title: "Descrição", text: $viewModel.game.description)
                                
                                HStack {
                                    FormNumberField(
                                        title: "Jogadores",
                                        sfSymbol: "person.2.fill",
                                        inText: "Mínimo",
                                        value: $numPlayersMin,
                                        onSubmitAction: {
                                            if let number = numPlayersMin {
                                                self.viewModel.game.numPlayersMin = number
                                            }
                                        },
                                        onChangeAction: {
                                        if let number = numPlayersMin {
                                            self.viewModel.game.numPlayersMin = number
                                        }
                                    })
                                    FormNumberField(
                                        title: " ",
                                        inText: "Máximo",
                                        value: $numPlayersMax,
                                        onSubmitAction: {
                                            if let number = numPlayersMax {
                                                self.viewModel.game.numPlayersMax = number
                                            }
                                        },
                                        onChangeAction: {
                                        if let number = numPlayersMax {
                                            self.viewModel.game.numPlayersMax = number
                                        }
                                    })
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Dificuldade")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.roxo)
                                    Picker("Dificuldade", selection: $viewModel.game.difficult) {
                                        ForEach(GameDifficult.allCases, id: \.self) { difficult in
                                            Text(difficult.rawValue.capitalized).tag(difficult)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                
                                FormNumberField(title: "Duração", inText: "Duração", value: $duration) {
                                    if let duration = duration {
                                        self.viewModel.game.duration = duration
                                    }
                                } onChangeAction: {
                                    if let duration = duration {
                                        self.viewModel.game.duration = duration
                                    }
                                }

                            } else {
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
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    
                    Spacer()
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
                                        Task {
                                            await viewModel.leaveWaitingList()
                                        }
                                    },
                                    text: "Sair da fila",
                                    isDestructive: true)

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
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .defaultNavigationAppearence()
        .navigationTitle(viewModel.game.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditing.toggle()
                    if !isEditing {
                        Task {
                            await viewModel.updateGame()
                        }
                    }
                }) {
                    Text(isEditing ? "Salvar" : "Editar")
                }
            }
        }
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
    AdminGameView(
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
