//
//  StatusView.swift
//  BordADA
//
//  Created by Felipe Passos on 02/10/24.
//

import SwiftUI

struct StatusView: View {
    var id: String
    
    var body: some View {
        Text(id)
    }
}

#Preview {
    StatusView(id: "1234")
}
