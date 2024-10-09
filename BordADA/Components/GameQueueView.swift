//
//  GameQueueView.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//

import SwiftUI

struct GameQueueView: View {
    var currentPlayer: Player?
    var waitingPlayers: [Player]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Em uso por")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(Color.roxo)
                    .cornerRadius(10, corners: [.topLeft, .topRight])

                Text(currentPlayer?.name ?? "Nenhum jogador")
                    .font(.title2)
                    .foregroundStyle(Color.roxo)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                    .padding(.bottom, 6)
                    
            }
            .frame(width: 342)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 4)
                    .foregroundColor(.roxo)
            }
            .padding(.horizontal)
            .padding(.top)


            if !waitingPlayers.isEmpty {
                // Fila de Jogadores
                VStack(alignment: .leading) {
                    Text("Fila")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .background(Color.roxo)
                        .cornerRadius(10, corners: [.topLeft, .topRight])

                    VStack(alignment: .leading) {
                        ForEach(waitingPlayers, id: \.id) { player in
                            Text(player.name)
                                .font(.body)
                                .padding(.horizontal, 10)
                                .foregroundStyle(Color.roxo)
                                .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                        }
                        .padding(.vertical, 1)
                    }
                    .padding(.bottom, 6)
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                }
                .frame(width: 342)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 4)
                        .foregroundColor(.roxo)
                }
                .padding(.horizontal)
                .padding(.top)
            }

            Spacer()
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    GameQueueView(
        currentPlayer: Player(id: "1", name: "Afonso", email: "afonso@example.com"),
        waitingPlayers: [
            Player(id: "2", name: "André", email: "andre@example.com"),
            Player(id: "3", name: "Alves", email: "alves@example.com"),
            Player(id: "4", name: "Michels", email: "michels@example.com"),
            Player(id: "5", name: "Sei lá quem", email: "seila@example.com")
        ]
    )
}
