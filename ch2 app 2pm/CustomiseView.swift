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
                    //                    if let image = UIImage(named: chosenImageName) {
                    //                        Image(uiImage: image)
                    //                            .resizable()
                    //                            .scaledToFit()
                    //                            .frame(width: 500, height: 500)
                    //                    }
                    //
                    ScrollView {
                        Text("Click on the part you want to customise!")
                        CustomiseEyesView()
                        CustomiseNoseView()
                        CustomiseLipsView()
                        CustomiseTorsoView()
                        CustomiseLegsView()
                        NavigationLink(destination: FiltersView()) {
                            Text("Next")
                            
                        }
                    }
                    .navigationTitle("Customise")
                }
            }
        }
    }
}

#Preview {
    CustomiseView()
}
