//
//  GameListView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI
import FirebaseAuth


struct GameListView: View {
    @StateObject var vm = GamesCollectionManager()
    @State var isShowing: Bool = false
    @State private var userName: String = "Player"


    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            HStack {
                Text(userName)
                    .font(.title)
                    .foregroundStyle(.white)
                    .bold()
                
                Spacer()
                
                Button {
                    isShowing = true
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title)
                        .foregroundStyle(.white)
                }
            

            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(.purple)
            
            ScrollView {
                LazyVStack {
                    ForEach(vm.gameList) { game in
                        Button {
                            router.push(to: .game(game))
                        } label: {
                            BoardGameListTile(game: game)
                        }
                        .buttonStyle(.plain)

                    }
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)
        }
        .background(Color.uiBackground)
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.userName = user.displayName ?? "Usuário"
            } else {
                self.userName = "Usuário não logado"
            }
            Task {
                await vm.fetchGames()
                print(vm.gameList.count)
            }
        }

        .sheet(isPresented: $isShowing) {
            ScannerView(isShowing: $isShowing) { value in
//                router.push(to: .game(value))
                print(value)
            }
            .presentationDetents([.medium, .large])
        }
        .navigationBarBackButtonHidden()
        
        Button(action: { self.isShowing.toggle() }) {
             Text("Scan")
         }
        Button {
            router.push(to: .gameCreate)
        } label: {
            Text("Criar Jogo")
        }
    }
}

#Preview {
    GameListView()
}
