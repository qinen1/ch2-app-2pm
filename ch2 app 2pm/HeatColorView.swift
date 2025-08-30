//
//  HeatColorView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 30/8/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct HeatColorView: View {
    let inputImage: UIImage
    
    var body: some View {
        if let heatImage = applyHeatSensor(to: inputImage) {
            Image(uiImage: heatImage)
                .resizable()
                .scaledToFit()
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
}

#Preview {
    HeatColorView(inputImage: UIImage(named: "james")!)
}
