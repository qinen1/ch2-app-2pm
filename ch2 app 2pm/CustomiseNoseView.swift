//
//  CustomiseNoseView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 22/8/25.
//

import SwiftUI

struct CustomiseNoseView: View {
    @State private var sheetPresentedNose = false
    @State private var nose1Clicked = true
    @State private var nose2Clicked = false
    var body: some View {
        Button {
            sheetPresentedNose = true
        } label: {
            if nose1Clicked == true {
                Image("nose1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 45)
            } else {
                Image("nose2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 45)
            }
        }
        .sheet(isPresented: $sheetPresentedNose) {
            VStack {
                Button {
                    nose1Clicked = true
                    nose2Clicked = false
                } label: {
                    Image("nose1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 125, height: 45)
                }
                Button {
                    nose1Clicked = false
                    nose2Clicked = true
                } label: {
                    Image("nose2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 125, height: 45)
                }
                .presentationDetents([.fraction(0.3)])
            }
        }
    }
}

#Preview {
    CustomiseNoseView()
}
