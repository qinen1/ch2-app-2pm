//
//  CustomiseLegsView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 22/8/25.
//

import SwiftUI

struct CustomiseLegsView: View {
    @State private var sheetPresentedLegs = false
    @State private var legs1Clicked = true
    @State private var legs2Clicked = false
    var body: some View {
        Button {
            sheetPresentedLegs = true
        } label: {
            if legs1Clicked == true {
                Image("legs1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 400)
            } else {
                Image("legs2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 400)
            }
        }
        .sheet(isPresented: $sheetPresentedLegs) {
            VStack {
                Button {
                    legs1Clicked = true
                    legs2Clicked = false
                } label: {
                    Image("legs1")
                        .resizable()
                        .scaledToFit()
                }
                Button {
                    legs1Clicked = false
                    legs2Clicked = true
                } label: {
                    Image("legs2")
                        .resizable()
                        .scaledToFit()
                }
                .presentationDetents([.fraction(0.5)])
            }
        }
    }
}

#Preview {
    CustomiseLegsView()
}
