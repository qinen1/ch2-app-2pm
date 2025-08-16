//
//  CustomiseView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 16/8/25.
//

import SwiftUI

struct CustomiseView: View {
    @State private var chosenImageName: String = "james"
    
    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    if let image = UIImage(named: chosenImageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 500)
                    }
                    
                    Text("Click on the part you want to customise!")
                        .offset(y: -550)
                        .navigationTitle("Customise")
                }
            }
        }
    }
}

#Preview {
    CustomiseView()
}
