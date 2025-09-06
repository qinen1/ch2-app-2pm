//
//  CustomiseView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 16/8/25.
//
import SwiftUI
import Foundation
import Vision
import UIKit
struct CustomiseView: View {
    @State private var selectedPart: SelectedPart?
    let inputImage1: UIImage
    let inputImage2: UIImage
    
    @StateObject private var detector1 = PoseDetector()
    @StateObject private var detector2 = PoseDetector()
    
    // optional: order to draw/tap
    private let displayOrder: [BodyPart] = [.face, .torso, .legs]
    
    var body: some View {
        VStack {
            NavigationStack {
                VStack(spacing: 12) {
                    Text("Click on the part you want to customize!")
                    
                    BoundedImage(image: inputImage1) { fit in
                        // Map image-space rects to view-space and sort largest → smallest
                        let pairs: [(BodyPart, CGRect)] =
                        detector1.parts
                            .map { ($0.key, fit.viewRect(fromImageRect: $0.value)) }
                            .sorted { $0.1.area > $1.1.area } // big first, small last (on top)
                        
                        ForEach(pairs, id: \.0) { part, vRect in
                            // stroke
                            Rectangle().path(in: vRect)
                                .strokedPath(.init(lineWidth: 1))
                                .foregroundStyle(.blue)
                                .allowsHitTesting(false) // stroke shouldn't grab taps
                            
                            // tappable hit-area
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .frame(width: vRect.width, height: vRect.height)
                                .position(x: vRect.midX, y: vRect.midY)
                                .onTapGesture {
                                    if let r = detector1.parts[part] {
                                        selectedPart = SelectedPart(bodyPart: part, rectInImageSpace: r)
                                    }
                                }
                        }
                    }
                    .frame(height: 300)
                    NavigationLink(destination: FiltersView(finalImage: inputImage1)) {
                        Text("Next")
                    }
                }
                .navigationTitle("Customize")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    await detector1.process(image: inputImage1)
                    await detector2.process(image: inputImage2)
                }
            }
        }
        .sheet(item: $selectedPart) { part in
            PartSheet(
                part: part,
                rects1: detector1.parts,
                rects2: detector2.parts,
                image1: inputImage1,
                image2: inputImage2
            )
            .presentationDetents([.medium])
        }
    }
}
private struct SelectedPart: Identifiable {
    let id = UUID()
    let bodyPart: BodyPart
    let rectInImageSpace: CGRect
}

/// Generic image container that draws an overlay using image→view mapping.
struct BoundedImage<Overlay: View>: View {
    let image: UIImage
    @ViewBuilder var content: (_ fit: FitInfo) -> Overlay
    
    var body: some View {
        GeometryReader { geo in
            let fit = FitInfo(container: geo.size, imageSize: image.size)
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                content(fit)   // ← your rectangles/dots use `fit` here
            }
        }
        // Height comes from the caller via `.frame(height: ...)`
    }
}
/// Coordinate mapper for `.scaledToFit()`
/// when img is scaled to fit, its shrunk (scaled and centred)and the coords of the body part that vision tells you may not be lined up anymore
struct FitInfo {
    let scale: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    let imageSize: CGSize
    let containerSize: CGSize
    
    init(container: CGSize, imageSize: CGSize) {
        self.containerSize = container
        self.imageSize = imageSize
        let sx = container.width / imageSize.width
        let sy = container.height / imageSize.height
        scale = min(sx, sy)
        let drawn = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        xOffset = (container.width - drawn.width) / 2
        yOffset = (container.height - drawn.height) / 2
    }
    
    func viewRect(fromImageRect r: CGRect) -> CGRect {
        CGRect(
            x: r.minX * scale + xOffset,
            y: r.minY * scale + yOffset,
            width: r.width * scale,
            height: r.height * scale
        )
    }
}
private struct PartSheet: View {
    let part: SelectedPart
    let rects1: [BodyPart: CGRect]
    let rects2: [BodyPart: CGRect]
    let image1: UIImage
    let image2: UIImage
    
    var cropLeft: UIImage? {
        guard let r = rects1[part.bodyPart] else { return nil }
        return image1.cropped(toImagePoints: r)
    }
    var cropRight: UIImage? {
        guard let r = rects2[part.bodyPart] else { return nil }
        return image2.cropped(toImagePoints: r)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let img = cropLeft {
                Image(uiImage: img)
                    .resizable().scaledToFit()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if let img = cropRight {
                Image(uiImage: img)
                    .resizable().scaledToFit()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
}
// to prevent app from crashing when detector can't find same part in both images
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index]: nil
    }
}
// takes the rectangle (from vision) and crops the UIImage to just that part, point (vision's rectangles) to pixel (uiimage) conversion
private extension UIImage {
    // crop using a rect in points
    func cropped (toImagePoints rect: CGRect) -> UIImage? {
        guard let cg = self.cgImage else { return nil }
        let scale = self.scale
        // from points to pixels
        var pixelRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale
        ).integral
        // clamp to bounds: Sometimes Vision’s rect may be slightly outside the image edge → intersecting ensures we never request a crop outside the valid pixel area.
        let bounds = CGRect(x: 0, y: 0, width: cg.width, height: cg.height)
        pixelRect = pixelRect.intersection(bounds)
        guard !pixelRect.isNull,
              let cropped = cg.cropping(to: pixelRect) else { return nil }
        return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
    }
}
private extension CGRect {
    var area: CGFloat { max(0, width) * max(0, height) }
}

#Preview {
    if let img1 = UIImage(named: "james"), let img2 = UIImage(named: "TestImage2") {
        CustomiseView(inputImage1: img1, inputImage2: img2)
    }
}

