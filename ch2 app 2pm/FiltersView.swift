import SwiftUI

struct FiltersView: View {
    enum Filter: String {
        case none, greyscale, invertedColors, heatColor
    }
    var finalImage: UIImage?
    @State private var selected: Filter = .none
    var body: some View {
        NavigationStack {
            VStack {
                if let ui = finalImage {
                    switch selected {
                    case .none:
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                    case .greyscale:
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .grayscale(1.0)
                    case .invertedColors:
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .colorInvert()
                    case .heatColor:
                        if let heatImage = applyHeatSensor(to: ui) {
                            Image(uiImage: heatImage)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Button {
                        selected = .greyscale
                        
                    } label: {
                        Text("Greyscale")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                    
                    Button {
                        selected = .invertedColors
                    } label: {
                        Text("Inverted Colors")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                    Button {
                        selected = .heatColor
                    } label: {
                        Text("Heat Color")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                    Button {
                        selected = .none
                    } label: {
                        Text("No Filter")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                    NavigationLink(destination: FinalProductView(finalImage: finalImage, filter: selected)) {
                        Text("Next")
                    }
                    .navigationTitle("Filters")
                    
                }
            }
        }
    }
}
func applyHeatSensor(to image: UIImage) -> UIImage? {
    let context = CIContext()
    let ciImage = CIImage(image: image)
    
    // False color filter (dark → blue, light → red/yellow)
    let filter = CIFilter.falseColor()
    filter.inputImage = ciImage
    filter.color0 = CIColor(red: 0.0, green: 0.0, blue: 1.0)   // cold = blue
    filter.color1 = CIColor(red: 1.0, green: 0.5, blue: 0.0)   // hot = orange-red
    
    guard let output = filter.outputImage,
          let cgimg = context.createCGImage(output, from: output.extent) else {
        return nil
    }
    return UIImage(cgImage: cgimg)
}
#Preview {
    FiltersView(finalImage: UIImage(named: "james"))
}

