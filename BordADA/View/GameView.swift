//
//  GameView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI
import RouterKit

struct GameView: View {
    var id: String
    
    @State var apiResult: String = ""
    @State var isShowing: Bool = false
    
    @EnvironmentObject var router: Router<AppRoute>
    
    var body: some View {
        VStack {
            Text(id)
            
            Text("Jogadores: 3 a 5")
            Text("Quest é um jogo foda de fazer coisas fodas bla bla bla bla")
            
            Text(apiResult)
            
            Button(action: { self.isShowing.toggle() }) {
                Text("Entrar no jogo")
            }
        }
        .navigationTitle("Quest")
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
