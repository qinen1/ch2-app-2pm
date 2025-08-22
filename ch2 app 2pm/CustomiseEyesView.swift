//
//  CustomiseEyesView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 22/8/25.
//

import SwiftUI

struct CustomiseEyesView: View {
    @State private var sheetPresentedEyes = false
    @State private var eyes1Clicked = true
    @State private var eyes2Clicked = false
    var body: some View {
        Button {
            sheetPresentedEyes = true
        } label: {
            if eyes1Clicked == true {
                Image("eyes1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 210, height: 50)
            } else {
                Image("eyes2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 210, height: 55)
            }
        }
        .sheet(isPresented: $sheetPresentedEyes) {
            VStack {
                Button {
                    eyes1Clicked = true
                    eyes2Clicked = false
                } label: {
                    Image("eyes1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 50)
                }
                Button {
                    eyes1Clicked = false
                    eyes2Clicked = true
                } label: {
                    Image("eyes2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 55)
                }
                .presentationDetents([.fraction(0.3)])
            }
        }

    }
}

#Preview {
    CustomiseEyesView()
}
