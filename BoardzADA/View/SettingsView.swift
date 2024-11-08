//
//  SettingsView.swift
//  BoardzADA
//
//  Created by André Wozniack on 07/11/24.
//

import SwiftUI
import UIKit
import RouterKit

struct SettingsView: View {
    @StateObject var vm = GamesCollectionManager.shared
    @ObservedObject var userManager = UserManager.shared
    @EnvironmentObject var router: Router<AppRoute>
    @State private var showDeleteAlert = false
    
    var body: some View {
        if userManager.currentUser != nil {
            VStack {
                DefaultButton(action: {
                    Task {
                        vm.stopListening()
                        router.replaceRootView(to: .signIn)
                        await userManager.logout()

                    }
                }, text: "Logout")
                Divider()
                DefaultButton(
                    action: {
                        showDeleteAlert.toggle()
                    },
                    text: "Deletar conta",
                    isDestructive: true)
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Excluir Conta"),
                    message: Text("Tem certeza de que deseja excluir sua conta? Essa ação não pode ser desfeita."),
                    primaryButton: .destructive(Text("Excluir")) {
                        Task {
                            vm.stopListening()
                            let success = await userManager.deleteAccount()
                            if success {
                                router.replaceRootView(to: .signIn)
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("Cancelar"))
                )
            }
            .defaultNavigationAppearence()
            .navigationTitle("Configurações")
        } else {
            DefaultButton(action: {router.pop()}, text: "Voltar")
        }
    }
}

#Preview {
    SettingsView()
}
