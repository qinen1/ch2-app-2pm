//
//  PoseDetector.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 23/8/25.
//
//Your code now:
//Loops over all detected joints and draws a small rectangle per joint or bounding box Vision gives you.
//Those are just “raw rectangles,” indexed in an array (partRectsInImageSpace[0], [1], [2] …).
//When you tap, you only know “rect at index 3 was tapped.” You don’t actually know whether index 3 = eyes, torso, or legs.
//With rectFor + BodyPart enum:
//Instead of treating every rect as an anonymous index, you group joints into meaningful regions (eyes, torso, legs, etc.).
//You then create one bounding rect per group by calling rectFor([...]).
//That way, you store partRects = [.face: rect, .torso: rect, .legs: rect].
//When you tap, you know exactly which BodyPart was tapped, not just “index 3.”
import Vision
import UIKit

// Semantic regions we expose to the UI
enum BodyPart: Hashable {
    case face, torso, legs
}

final class PoseDetector: ObservableObject {
    // Whole-person box in IMAGE PIXELS
    @Published var personRectInImageSpace: CGRect = .null
    // Labeled part rectangles in IMAGE PIXELS
    @Published var parts: [BodyPart: CGRect] = [:]
    
    private let confidenceThreshold: VNConfidence = 0.25
    
    func process(image: UIImage) async {
        guard let cg = image.cgImage else { return }
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(
            cgImage: cg,
            orientation: Self.cgImageOrientation(from: image.imageOrientation)
        )
        do {
            try handler.perform([request])
            guard let obs = request.results?.first else {
                await MainActor.run {
                    self.personRectInImageSpace = .null
                    self.parts = [:]
                }
                return
            }
            // 1) Collect joint points in IMAGE PIXELS (UIKit top-left)
            let rawPoints = try obs.recognizedPoints(.all)
                .filter { $0.value.confidence >= confidenceThreshold }
                .mapValues { p in
                    CGPoint(
                        x: CGFloat(p.x) * image.size.width,
                        y: (1 - CGFloat(p.y)) * image.size.height
                    )
                }
            // 2) Whole-person rect derived from all joints (no boundingBox use)
            let personRect = Self.rectFor(points: Array(rawPoints.values), pad: 10)
            
            // 3) Labeled part rects from joint groups
            let faceJoints:  [VNHumanBodyPoseObservation.JointName] =
            [.nose, .leftEye, .rightEye, .leftEar, .rightEar]
            let torsoJoints: [VNHumanBodyPoseObservation.JointName] =
            [.neck, .leftShoulder, .rightShoulder, .leftHip, .rightHip]
            let legsJoints:  [VNHumanBodyPoseObservation.JointName] =
            [.leftHip, .rightHip, .leftKnee, .rightKnee, .leftAnkle, .rightAnkle]
            func rectFor(_ joints: [VNHumanBodyPoseObservation.JointName], pad: CGFloat = 8) -> CGRect {
                let pts = joints.compactMap { rawPoints[$0] }
                return Self.rectFor(points: pts, pad: pad)
            }
            // Compute as lets (immutable)
            let faceRect  = rectFor(faceJoints)
            let torsoRect = rectFor(torsoJoints)
            let legsRect  = rectFor(legsJoints)
            // 4) Publish on the main actor; build the dict INSIDE the closure
            await MainActor.run {
                self.personRectInImageSpace = personRect
                var dict: [BodyPart: CGRect] = [:]
                if !faceRect.isNull  { dict[.face]  = faceRect  }
                if !torsoRect.isNull { dict[.torso] = torsoRect }
                if !legsRect.isNull  { dict[.legs]  = legsRect  }
                self.parts = dict
            }
        } catch {
            await MainActor.run {
                self.personRectInImageSpace = .null
                self.parts = [:]
            }
        }
    }
    // MARK: - Helpers
    
    /// Bounding rect for a set of points (IMAGE PIXELS). Returns .null if empty.
    private static func rectFor(points: [CGPoint], pad: CGFloat) -> CGRect {
        guard !points.isEmpty,
              let minX = points.map(\.x).min(),
              let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(),
              let maxY = points.map(\.y).max() else {
            return .null
        }
        return CGRect(
            x: minX - pad,
            y: minY - pad,
            width: (maxX - minX) + 2 * pad,
            height: (maxY - minY) + 2 * pad
        )
    }
    
    /// Convert Vision's normalized rect (bottom-left origin) to IMAGE PIXELS (top-left origin)
    private static func pixelRect(fromNormalized r: CGRect, imageSize: CGSize) -> CGRect {
        guard r.width > 0, r.height > 0 else { return .null }
        let x = r.minX * imageSize.width
        let y = (1 - r.maxY) * imageSize.height     // flip + shift
        let w = r.width  * imageSize.width
        let h = r.height * imageSize.height
        return CGRect(x: x, y: y, width: w, height: h)
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
