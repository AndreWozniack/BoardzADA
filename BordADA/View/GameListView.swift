//
//  GameListView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI
import RouterKit

struct GameListView: View {
    @ObservedObject var vm = GameListViewModel()
    @State var isShowing: Bool = false
    
    @EnvironmentObject var router: Router<AppRoute>
    
    var body: some View {
        VStack {
            List {
                ForEach(vm.gameList) { game in
                    GameListTile(game: game)
                }
            }
            .onAppear {
                Task {
                    await vm.load()
                }
            }
            
            Button(action: { self.isShowing.toggle() }) {
                 Text("Scan")
             }
        }
        .toolbar { EditButton() }
        .sheet(isPresented: $isShowing) {
             ScannerView(isShowing: $isShowing)
                 .presentationDetents([.medium, .large])
         }
    }
}

struct GameListTile: View {
    let game: BoardGame
    
    func getColor() -> Color {
        switch(game.status) {
            case .free: .green
            case .occupied: .red
            case .reserved: .red
            case .waiting: .yellow
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(game.name)
                    .font(.headline)
                
                Circle()
                    .foregroundStyle(.red)
                    .frame(height: 10)
            }
            
            Text(game.description)
                .font(.subheadline)
        }
    }
}

#Preview {
    GameListView()
}
