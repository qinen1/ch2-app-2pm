//
//  GreyscaleView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 30/8/25.
//


import SwiftUI

struct GreyscaleView: View {
    var finalImage: Image?
    
    var body: some View {
        NavigationStack {
            VStack {
                finalImage?
                    .resizable()
                    .scaledToFit()
                    .grayscale(1.0) // 1.0 = full greyscale, 0.0 = normal image
                
                Spacer()
            }
            .navigationTitle("Filters")
        }
    }
}

#Preview {
    GreyscaleView(finalImage: Image("james"))
}
