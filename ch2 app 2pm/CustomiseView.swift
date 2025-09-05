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
    // model to store which rect was tapped (and from which image)
    @State private var selectedPart: SelectedPart?
    @State private var selectedPart2: SelectedPart?
    var inputImage1: UIImage
    var inputImage2: UIImage
    @StateObject private var detector1 = PoseDetector()
    @StateObject private var detector2 = PoseDetector()
    var rectInImageSpace: CGRect {
        CGRect(x: 100, y: 100, width: 200, height: 300)
    }
    var body: some View {
        VStack {
            ScrollView {
                VStack() {
                    Text("Click on the part you want to customize!")
                    BoundedImage(image: inputImage1) { fit in
                        ForEach(Array(detector1.partRectsInImageSpace.indices), id: \.self) { idx in
                            let r = detector1.partRectsInImageSpace[idx]
                            let vRect = fit.viewRect(fromImageRect: r)
                            Rectangle().path(in: vRect)
                                .strokedPath(.init(lineWidth: 1))
                                .foregroundStyle(.blue)
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .frame(width: vRect.width, height: vRect.height)
                                .position(x: vRect.midX, y: vRect.midY)
                                .onTapGesture {
                                    selectedPart = SelectedPart(source: 0, index: idx, rectInImageSpace: r)
                                }
                        }
                    }
                    .frame(height: 300)
                    BoundedImage(image: inputImage2) { fit in
                        ForEach(Array(detector2.partRectsInImageSpace.indices), id: \.self) { idx in
                            let r = detector2.partRectsInImageSpace[idx]
                            let vRect = fit.viewRect(fromImageRect: r)
                            Rectangle().path(in: vRect)
                                .strokedPath(.init(lineWidth: 1))
                                .foregroundStyle(.blue)
                            Rectangle()
                                .fill(.clear)
                                .frame(width: vRect.width, height: vRect.height)
                                .position(x: vRect.midX, y: vRect.midY)
                                .onTapGesture {
                                    selectedPart2 = SelectedPart(source: 1, index: idx, rectInImageSpace: r)
                                }
                        }
                    }
                    .frame(height: 300)
                    
                }
                .task {
                    await detector1.process(image: inputImage1)
                    await detector2.process(image: inputImage2)
                }
                .sheet(item: $selectedPart) { part in
                    PartSheet(part: part, rects1: detector1.partRectsInImageSpace, rects2: detector2.partRectsInImageSpace, image1: inputImage1, image2: inputImage2)
                        .presentationDetents([.medium])
                }
                .navigationTitle("Customise")
                .navigationBarTitleDisplayMode(.inline)
                NavigationLink(destination: FiltersView()) { Text("Next")
                }
            }
            .navigationTitle("Customize")
        }
    }
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
    
    func viewPoint(fromImagePoint p: CGPoint) -> CGPoint {
        CGPoint(x: p.x * scale + xOffset, y: p.y * scale + yOffset)
    }
}
// model to store which rect was tapped (and from which image)
private struct SelectedPart: Identifiable {
    let id = UUID()
    let source: Int // 0 =  first image, 1 = second image
    let index: Int // index in partRects array (or 0 for whole person)
    let rectInImageSpace: CGRect
}
// sheet
private struct PartSheet: View {
    let part: SelectedPart
    let rects1: [CGRect]
    let rects2: [CGRect]
    let image1: UIImage
    let image2: UIImage
    
    var cropLeft: UIImage? {
        rects1[safe: part.index].flatMap { image1.cropped(toImagePoints: $0)
        }
    }
    var cropRight: UIImage? {
        rects2[safe: part.index].flatMap {
            image2.cropped(toImagePoints: $0)
        }
    }
    var body: some View {
        HStack() {
            if let img = cropLeft {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if let img = cropRight {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
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
#Preview {
    if let img1 = UIImage(named: "james"), let img2 = UIImage(named: "TestImage2") {
        CustomiseView(inputImage1: img1, inputImage2: img2)
    }
}

