//
//  FinalProductView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 16/8/25.
//

import SwiftUI
import UniformTypeIdentifiers // needed for UTType (e.g. png)
struct FinalProductView: View {
    var finalImage: UIImage?
    var filter: FiltersView.Filter
    @State private var shareImage: UIImage? = nil
    var body: some View {
        VStack {
            NavigationStack {
                if let img = finalImage {
                    switch filter {
                    case .none:
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                    case .greyscale:
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .grayscale(1.0)
                    case .invertedColors:
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .colorInvert()
                    case .heatColor:
                        if let heatImage = applyHeatSensor(to: img) {
                            Image(uiImage: heatImage)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                if let img = shareImage {
                    ShareLink(item: ShareableImage(image: img), preview: SharePreview("Final Product", image: Image(uiImage: img)))
                        .padding()
                }
                Spacer()
                NavigationLink(destination: ContentView()) {
                    Text("Make more!")
                }
                .navigationTitle("Final Product")
            }
        }
        .onAppear {
            if shareImage == nil
            {
                let w = UIScreen.main.bounds.width * 2
                shareImage = renderFilteredUIImage(
                    image: finalImage,
                    filter: filter,
                    canvas: CGSize(width: w, height: w)
                    // makes shareImage a real UIImage
                )
            }
        }
    }
}
struct ShareableImage: Transferable
// Transferable: for swiftui to know how to share it in ShareLink
{
    let image: UIImage
    static var transferRepresentation: some TransferRepresentation
    // tells the system how it is turned into data
    {
        DataRepresentation(exportedContentType: .png) { value in
            value.image.pngData() // stored UIImage and converts it to PNG bytes
            ?? Data()
        }
    }
}
// convert swiftui view to UIimage so that filters show up when shared
@MainActor func renderFilteredUIImage(image: UIImage?, filter: FiltersView.Filter, canvas: CGSize) -> UIImage? {
    let content: some View = Group {
        if let image {
            switch filter {
            case .none:
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            case .greyscale:
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .grayscale(1.0)
            case .invertedColors:
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .colorInvert()
            case .heatColor:
                if let heatImage = applyHeatSensor(to: image) {
                    Image(uiImage: heatImage)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
        .frame(width: canvas.width, height: canvas.height)
    let renderer = ImageRenderer(content: content)
    renderer.scale = UIScreen.main.scale
    return renderer.uiImage
}
#Preview {
    FinalProductView(finalImage: UIImage(named: "james"), filter: .none)
}
