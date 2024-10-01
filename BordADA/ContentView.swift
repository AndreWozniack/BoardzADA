//
//  ContentView.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//

import AVFoundation  //import to access barcode types you want to scan
import CarBode
import SwiftUI

struct ContentView: View {
	@State var isShowing: Bool = false
	var body: some View {
		ZStack {
			Button(action: { self.isShowing.toggle() }) {
				Text("Scan")
			}
		}
			.sheet(isPresented: $isShowing) {
				ScannerView(isShowing: $isShowing)
					.presentationDetents([.medium, .large])
			}
	}
}

#Preview {
	ContentView()
}
