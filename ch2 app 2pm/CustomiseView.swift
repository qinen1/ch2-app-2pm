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
    @State private var chosenImageName: String = "james"
    var inputImage1: UIImage
    var inputImage2: UIImage
    @StateObject private var detector1 = PoseDetector()
    @StateObject private var detector2 = PoseDetector()
    var rectInImageSpace: CGRect {
        CGRect(x: 100, y: 100, width: 200, height: 300)
    }
    var body: some View {
        VStack {
            //                VStack {
            //                    //                    if let image = UIImage(named: chosenImageName) {
            //                    //                        Image(uiImage: image)
            //                    //                            .resizable()
            //                    //                            .scaledToFit()
            //                    //                            .frame(width: 500, height: 500)
            //                    //                    }
            //                    //
            //                    ScrollView {
            //                        Text("Click on the part you want to customise!")
            //                        CustomiseEyesView()
            //                        CustomiseNoseView()
            //                        CustomiseLipsView()
            //                        CustomiseTorsoView()
            //                        CustomiseLegsView()
            //                        NavigationLink(destination: FiltersView()) {
            //                            Text("Next")
            //
            //                        }
            //                    }
            ScrollView {
                VStack(spacing: 40) {
                    // Image 1: whole-person rect
                    BoundedImage(image: inputImage1) { fit in
                        if !detector1.personRectInImageSpace.isNull {
                            let vRect = fit.viewRect(fromImageRect: detector1.personRectInImageSpace)
                            Rectangle().path(in: vRect)
                                .strokedPath(.init(lineWidth: 3))
                                .foregroundStyle(.red)
                        }
                    }
                    .frame(height: 300)
                    
                    // Image 2: multiple part rects
                    BoundedImage(image: inputImage2) { fit in
                        ForEach(Array(detector2.partRectsInImageSpace.enumerated()), id: \.offset) { _, r in
                            let vRect = fit.viewRect(fromImageRect: r)
                            Rectangle().path(in: vRect)
                                .strokedPath(.init(lineWidth: 2))
                                .foregroundStyle(.blue)
                        }
                    }
                    .frame(height: 300)
                    
                }
                .task {
                    await detector1.process(image: inputImage1)
                    await detector2.process(image: inputImage2)
                }
                .navigationTitle("Customise")
                .navigationBarTitleDisplayMode(.inline)
                NavigationLink(destination: FiltersView()) { Text("Next")
                }
            }
            .navigationTitle("Customise")
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
#Preview {
    if let img1 = UIImage(named: "james"), let img2 = UIImage(named: "TestImage2") {
        CustomiseView(inputImage1: img1, inputImage2: img2)
    }
}
