//
//  ScannerView.swift
//  BordADA
//
//  Created by Afonso Rekbaim on 01/10/24.
//

import SwiftUI
import AVFoundation
import CarBode
import RouterKit

struct ScannerView: View {
	@Binding var isShowing: Bool
    
    var onScan: (String) -> Void?
    
    var body: some View {
		ZStack{
			CBScanner(
				supportBarcode: .constant([.qr]),
				scanInterval: .constant(5.0)
			) {
				print("QRCode: ", $0.value)
				isShowing = false
                onScan($0.value)
			}
            
			Rectangle()
				.fill(Color.black)
				.opacity(0.5)
				.reverseMask{
					Rectangle()
						.frame(width: 150, height: 150)
				}
		}
    }
}

extension View {
	@ViewBuilder func reverseMask<Mask: View>(
		alignment: Alignment = .center,
		@ViewBuilder _ mask: () -> Mask
	) -> some View {
		self.mask {
			Rectangle()
				.overlay(alignment: alignment) {
					mask()
						.blendMode(.destinationOut)
				}
		}
	}
}
