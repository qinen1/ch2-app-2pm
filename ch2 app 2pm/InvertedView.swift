//
//  InvertedView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 30/8/25.
//

import SwiftUI

struct InvertedView: View {
    var finalImage: Image?

    var body: some View {
        NavigationStack {
            VStack {
                if let finalImage = finalImage {
                    finalImage
                        .resizable()
                        .scaledToFit()
                        .colorInvert() // 👈 easiest option
                }
                Spacer()
            }
            .navigationTitle("Filters")
        }
    }
}

#Preview {
    InvertedView(finalImage: Image("james"))
}
