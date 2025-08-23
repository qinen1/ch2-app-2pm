//
//  PoseOverlay.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 23/8/25.
//

import SwiftUI
import Vision

struct PoseOverlay: View {
    var observations: [VNHumanBodyPoseObservation]
    
    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                for obs in observations {
                    // Draw joints
                    if let points = try? obs.recognizedPoints(.all) {
                        for (_, p) in points {
                            guard p.confidence > 0.3 else { continue }
                            let x = p.x * size.width
                            let y = (1 - p.y) * size.height
                            ctx.fill(Path(ellipseIn: CGRect(x: x-3, y: y-3, width: 6, height: 6)), with: .color(.red))
                        }
                    }
                }
            }
        }
    }
}
