//
//  ContentView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 2/8/25.
//

import SwiftUI
import PhotosUI
struct ContentView: View {
    @State private var photoItem1: PhotosPickerItem?
    @State private var photoItem2: PhotosPickerItem?
    @State private var chosenImage1: Image?
    @State private var chosenImage2: Image?
    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    PhotosPicker("Upload Person 1", selection: $photoItem1, matching: .images)
                    chosenImage1?
                        .resizable()
                        .scaledToFit()
                }
                .onChange(of: photoItem1) {
                    Task {
                        if let loaded = try? await photoItem1?.loadTransferable(type: Image.self) {
                            chosenImage1 = loaded
                        } else {
                            print("Failed")
                        }
                    }
                }
                VStack {
                    PhotosPicker("Upload Person 2", selection: $photoItem2, matching: .images)
                    chosenImage2?
                        .resizable()
                        .scaledToFit()
                }
                .onChange(of: photoItem2) {
                    Task {
                        if let loaded = try? await photoItem2?.loadTransferable(type: Image.self) {
                            chosenImage2 = loaded
                        } else {
                            print("Failed")
                        }
                    }
                }
                HStack {
                    NavigationLink(destination: FinalProductView()) {
                        Text("Randomise")
                    }
                    NavigationLink(destination: CustomiseView()) {
                        Text("Customise")
                    }
                }
                .navigationTitle("Photos")
            }
        }
        .padding()
    }
}
#Preview {
    ContentView()
}
