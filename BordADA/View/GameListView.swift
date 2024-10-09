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
    @ObservedObject var userManager = UserManager.shared
    @State var isShowing: Bool = false

    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
<<<<<<< HEAD
            HStack {
                Text(userManager.currentUser?.name ?? "Usuario nao logado")
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
=======
            ScrollView {
                Group {
                    Section {
                        VStack(alignment: .leading) {
                            LazyVStack {
                                ForEach(vm.gameList, id: \.id) { game in
                                    
                                    Button {
                                        router.push(to: .game(game))
                                    } label: {
                                        BoardGameListTile(game: game)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.vertical)
                    }

                }

>>>>>>> a6f3e4f (Implemented Game Queue and sync with db using listener. OccupiedGame changed to BoardGame. Now using ref to player in game not Player)
            }
            .padding(.horizontal, 24)
<<<<<<< HEAD
=======
            .refreshable {
                Task {
                    await vm.fetchGames()
                }
            }
            HStack{
                DefaultButton(action: { self.isShowing.toggle() }, text: "Scan")
                    .shadow(radius: 5)
                DefaultButton(action: { router.push(to: .gameSearch) }, text: "Criar Jogo")
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            .padding(.vertical)
>>>>>>> a6f3e4f (Implemented Game Queue and sync with db using listener. OccupiedGame changed to BoardGame. Now using ref to player in game not Player)
        }
        .defaultNavigationAppearence()
        .navigationTitle("BoardzADA")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.uiBackground)
        .onAppear {
            Task {
                await vm.fetchGames()
            }
        }
        .sheet(isPresented: $isShowing) {
            ScannerView(isShowing: $isShowing) { value in
<<<<<<< HEAD
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
=======
                Task {
                    guard let game = vm.freeGames.first(where: { $0.id.uuidString == value}) else {
                        print("Jogo não encontrado")
                        return
                    }
                    await GamesCollectionManager.shared.addCurrentPlayer(
                        to: game.id.uuidString,
                        playerID: userManager.currentUser!.id ?? ""
                    )
                    router.push(to: .game(game))
                }
            }
            .presentationDetents([.medium, .large])
        }
>>>>>>> a6f3e4f (Implemented Game Queue and sync with db using listener. OccupiedGame changed to BoardGame. Now using ref to player in game not Player)
    }
}

#Preview {
    GameListView()
}
