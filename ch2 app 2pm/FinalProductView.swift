//
//  FinalProductView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 16/8/25.
//

import SwiftUI

struct FinalProductView: View {
    var finalImage: Image?
    var body: some View {
        VStack {
            NavigationStack {
                finalImage?
                    .resizable()
                    .scaledToFit()
                if let finalImage {
                    ShareLink(item: finalImage, preview: SharePreview("Final Product", image: finalImage))
                        .padding()
                }
                Spacer()
                NavigationLink(destination: ContentView()) {
                    Text("Make more!")
                }
                    .navigationTitle("Final Product")
            }
        }
    }
}

#Preview {
    FinalProductView(finalImage: Image("james"))
}
