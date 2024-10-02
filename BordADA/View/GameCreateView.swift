//
//  GameCreateView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI

struct GameCreateView: View {
    @ObservedObject var vm = GameCreateViewModel()
    
    var body: some View {
        VStack {
            TextField(text: $vm.game.name) {
                Text("Nome")
            }
            
            TextField(text: $vm.game.owner) {
                Text("Responsável")
            }
            
            TextField(text: $vm.game.description) {
                Text("Descrição")
            }
            
            TextField("Quantidade mínima de jogadores", value: $vm.game.numPlayersMin, format: .number)
            .keyboardType(.decimalPad)
            
            TextField("Quantidade máxima de jogadores", value: $vm.game.numPlayersMin, format: .number)
            .keyboardType(.decimalPad)
            
            Picker("Status", selection: $vm.game.status) {
                Text("Livre").tag(GameStatus.free)
                Text("Ocupado").tag(GameStatus.occupied)
                Text("Reservado").tag(GameStatus.reserved)
                Text("Esperando").tag(GameStatus.waiting)
            }
            
            Button("Criar") {
                Task {
                    await vm.create()
                }
            }
        }
        .padding()
    }
}

#Preview {
    GameCreateView()
}
