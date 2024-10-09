//
//  TittleWithText.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//

import Foundation
import SwiftUI


struct TittleWithText: View {
    
    var title: String
    var sfSymbolTitle: String?
    var titleSize: CGFloat?
    var text: String
    var sfSymbol: String?
    var textSize: CGFloat?
    var isMultiline: Bool = false
    var alignment: HorizontalAlignment = .leading
    
    
    var body: some View {
        VStack(alignment: alignment, spacing: 10) {
            HStack (spacing: 4){
                if let symbol = sfSymbolTitle {
                    Text(.init(systemName: symbol))
                        .font(.system(size: titleSize ?? 20))
                        .fontWeight(.bold)
                        .foregroundColor(.roxo)
                }
                
                Text(title)
                    .font(.system(size: titleSize ?? 20))
                    .fontWeight(.bold)
                    .foregroundColor(.roxo)
            }
            HStack (spacing: 4){
                if let symbol = sfSymbol {
                    Text(.init(systemName: symbol))
                        .font(.system(size: textSize ?? 17))
                        .foregroundColor(.roxo)
                }
                
                if isMultiline {
                    Text(text)
                        .font(.system(size: textSize ?? 17))
                        .foregroundColor(.roxo)
                        .multilineTextAlignment(.leading)
                        
                } else {
                    Text(text)
                        .font(.system(size: textSize ?? 17))
                        .foregroundColor(.roxo)
                }
            }
            
        }
    }
}

#Preview {
    TittleWithText(title: "Descrição", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque  consequat sodales diam id dapibus. Nunc non posuere mauris, pellentesque suscipit velit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Cras et sagittis urna. Aliquam  lacus enim, mollis vulputate tincidunt id, finibus feugiat purus. Lorem  ipsum dolor sit amet, consectetur adipiscing elit. Integer rhoncus,  augue quis consequat efficitur, massa mi facilisis purus, vitae vehicula metus tortor id ante. Maecenas tincidunt tellus at varius tincidunt.  Pellentesque habitant morbi tristique senectus et netus et malesuada  fames ac turpis egestas.", isMultiline: true)
}
