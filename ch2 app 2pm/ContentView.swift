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
    @State private var chosenImage1: UIImage?
    @State private var chosenImage2: UIImage?
    @State private var navigate = false
    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(selection: $photoItem1, matching: .images) {
                    Label("Pick Image 1", systemImage: "photo")
                        .padding()
                        .background(.blue.opacity(0.2))
                        .clipShape(Capsule())
                }
                .onChange(of: photoItem1) {_, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let img = UIImage(data: data) {
                            chosenImage1 = img
                        }
                    }
                }
                if let image1 = chosenImage1 {
                    Image(uiImage: image1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 150)
                }
                PhotosPicker(selection: $photoItem2, matching: .images) {
                    Label("Pick Image 2", systemImage: "photo")
                        .padding()
                        .background(.green.opacity(0.2))
                        .clipShape(Capsule())
                }
                .onChange(of: photoItem2) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let img = UIImage(data: data) {
                            chosenImage2 = img
                        }
                    }
                }
                if let image2 = chosenImage2 {
                    Image(uiImage: image2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 150)
                }
                
                if chosenImage1 != nil && chosenImage2 != nil {
                    NavigationLink(destination: CustomiseView(inputImage1: chosenImage1!, inputImage2: chosenImage2!)) {
                        Text("Customise")
                    }
                }
                
            }
            .navigationTitle("Photos")
        }
        .padding()
    }
}
private extension UIImage {
    func normalized() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }
}
#Preview {
    ContentView()
}
