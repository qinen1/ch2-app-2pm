//
//  CustomiseTorsoView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 22/8/25.
//

import SwiftUI

struct CustomiseTorsoView: View {
    @State private var sheetPresentedTorso = false
    @State private var torso1Clicked = true
    @State private var torso2Clicked = false
    var body: some View {
        Button {
            sheetPresentedTorso = true
        } label: {
            if torso1Clicked == true {
                Image("torso1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 400)
            } else {
                Image("torso2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 400)
            }
        }
        .sheet(isPresented: $sheetPresentedTorso) {
            VStack {
                Button {
                    torso1Clicked = true
                    torso2Clicked = false
                } label: {
                    Image("torso1")
                        .resizable()
                        .scaledToFit()
                }
                Button {
                    torso1Clicked = false
                    torso2Clicked = true
                } label: {
                    Image("torso2")
                        .resizable()
                        .scaledToFit()
                }
                .presentationDetents([.fraction(0.5)])
            }
        }
    }
}

#Preview {
    CustomiseTorsoView()
}
