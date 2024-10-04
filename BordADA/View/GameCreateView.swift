//
//  GameCreateView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//
import SwiftUI

struct GameCreateView: View {
    @ObservedObject var vm = GameCreateViewModel()
    @State private var name: String = ""
    @State private var owner: String = ""
    @State private var description: String = ""
    @State private var numPlayersMin: Int = 1
    @State private var numPlayersMax: Int = 4
    @State private var status: GameStatus = .free
    @State private var difficult: GameDifficult = .easy
    @State private var errorMessage: String?
    @State private var isSaving: Bool = false
    @State private var duration: Int = 10
    @State private var imageUrl: String = ""
    
    var body: some View {
        VStack {
            TextField("Nome", text: $name)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Responsável", text: $owner)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Descrição", text: $description)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Quantidade mínima de jogadores", value: $numPlayersMin, format: .number)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Image URL", text: $imageUrl)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Quantidade máxima de jogadores", value: $numPlayersMax, format: .number)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Status", selection: $status) {
                ForEach(GameStatus.allCases, id: \.self) { status in
                    Text(status.rawValue.capitalized).tag(status)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Picker("Dificuldade", selection: $difficult) {
                ForEach(GameDifficult.allCases, id: \.self) { difficult in
                    Text(difficult.rawValue.capitalized).tag(difficult)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            if isSaving {
                ProgressView("Salvando jogo...")
            } else {
                Button("Criar") {
                    isSaving = true
                    Task {
                        do {
                            let game = try await vm.createAndSaveGame(
                                name: name,
                                owner: owner,
                                description: description,
                                numPlayersMin: numPlayersMin,
                                numPlayersMax: numPlayersMax,
                                status: status,
                                difficult: difficult,
                                duration: duration,
                                imageUrl: imageUrl
                            )
                            print("Jogo criado: \(game)")
                            resetFields()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                        isSaving = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .padding()
    }
    
    // Reseta os campos do formulário após o jogo ser criado
    func resetFields() {
        name = ""
        owner = ""
        description = ""
        numPlayersMin = 1
        numPlayersMax = 4
        status = .free
        difficult = .easy
        errorMessage = nil
    }
}

#Preview {
    GameCreateView()
}

