//
//  PoseDetector.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 23/8/25.
//

import Vision
import UIKit

final class PoseDetector: ObservableObject {
    @Published var personRectInImageSpace: CGRect = .null
    @Published var partRectsInImageSpace: [CGRect] = []
    
    private let confidenceThreshold: VNConfidence = 0.25
    
    func process(image: UIImage) async {
        guard let cg = image.cgImage else { return }
        let req = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(
            cgImage: cg,
            orientation: PoseDetector.cgImageOrientation(from: image.imageOrientation)
        )
        
        do {
            try handler.perform([req])
            guard let obs = req.results?.first else {
                await MainActor.run {
                    self.personRectInImageSpace = .null
                    self.partRectsInImageSpace = []
                }
                return
            }
            
            // Build joint points (IMAGE PIXELS)
            let points = try obs.recognizedPoints(.all)
                .filter { _, p in p.confidence >= confidenceThreshold }
                .mapValues { p in
                    CGPoint(
                        x: CGFloat(p.x) * image.size.width,
                        y: (1 - CGFloat(p.y)) * image.size.height   // flip Y
                    )
                }
            
            // WHOLE-PERSON RECT from all joints  (make it a let)
            let personRectPx = Self.rectFor(points: Array(points.values), pad: 10)
            
            // PART RECTS (all lets, no vars)
            let faceJoints:  [VNHumanBodyPoseObservation.JointName] = [.nose, .leftEye, .rightEye, .leftEar, .rightEar]
            let torsoJoints:  [VNHumanBodyPoseObservation.JointName] = [.neck, .leftShoulder, .rightShoulder, .leftHip, .rightHip]
            let legsJoints:   [VNHumanBodyPoseObservation.JointName] = [.leftHip, .rightHip, .leftKnee, .rightKnee, .leftAnkle, .rightAnkle]
            
            func rectFor(joints: [VNHumanBodyPoseObservation.JointName]) -> CGRect {
                Self.rectFor(points: joints.compactMap { points[$0] }, pad: 8)
            }
            
            // Build an immutable array; filter out .null
            let partRects: [CGRect] = [rectFor(joints: faceJoints),
                                       rectFor(joints: torsoJoints),
                                       rectFor(joints: legsJoints)]
                .filter { !$0.isNull }
            
            // Now assign on the main actor, capturing only immutable lets
            await MainActor.run {
                self.personRectInImageSpace = personRectPx
                self.partRectsInImageSpace  = partRects
            }
        } catch {
            await MainActor.run {
                self.personRectInImageSpace = .null
                self.partRectsInImageSpace = []
            }
        }
    }
    // MARK: - Helpers
    
    private static func rectFor(points: [CGPoint], pad: CGFloat) -> CGRect {
        guard !points.isEmpty,
              let minX = points.map({ $0.x }).min(),
              let maxX = points.map({ $0.x }).max(),
              let minY = points.map({ $0.y }).min(),
              let maxY = points.map({ $0.y }).max()
        else { return .null }
        
        return CGRect(
            x: minX - pad,
            y: minY - pad,
            width: (maxX - minX) + 2*pad,
            height: (maxY - minY) + 2*pad
        )
    }
    
    private static func cgImageOrientation(from ui: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch ui {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
