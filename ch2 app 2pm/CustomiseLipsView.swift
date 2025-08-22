//
//  CustomiseLipsView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 22/8/25.
//

import SwiftUI

struct CustomiseLipsView: View {
    @State private var sheetPresentedLips = false
    @State private var lips1Clicked = false
    @State private var lips2Clicked = true
    var body: some View {
        Button {
            sheetPresentedLips = true
        } label: {
            if lips1Clicked == true {
                Image("lips1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 165, height: 55)
            } else {
                Image("lips2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 60)
            }
        }
        .sheet(isPresented: $sheetPresentedLips) {
            VStack {
                Button {
                    lips1Clicked = true
                    lips2Clicked = false
                } label: {
                    Image("lips1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 165, height: 55)
                }
                Button {
                    lips1Clicked = false
                    lips2Clicked = true
                } label: {
                    Image("lips2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 60)
                }
                .presentationDetents([.fraction(0.3)])
            }
        }
    }
}

#Preview {
    CustomiseLipsView()
}
