//
//  Scene.swift
//  ARKit-Vision
//
//  Created by Jaf Crisologo on 2017-12-18.
//  Copyright © 2017 Jan Crisologo. All rights reserved.
//

import SpriteKit
import ARKit
import Vision

class Scene: SKScene {
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            DispatchQueue.global(qos: .background).async {
                do {
                    let model = try VNCoreMLModel(for: Inceptionv3().model)
                    let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                        DispatchQueue.main.async {
                            guard let results = request.results as? [VNClassificationObservation], let result = results.first else {
                                print("No results?")
                                return
                            }
                            
                            // Create a transform with a translation of 0.4 meters in front of the camera
                            var translation = matrix_identity_float4x4
                            translation.columns.3.z = -0.4
                            let transform = simd_mul(currentFrame.camera.transform, translation)
                            
                            // Add a new anchor to the session
                            let anchor = ARAnchor(transform: transform)
                            ARBridge.shared.anchorsToIdentities[anchor] = result.identifier
                            
                            sceneView.session.add(anchor: anchor)
                        }
                    })
                    let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, options: [:])
                    try handler.perform([request])
                } catch {
                    // Handle catch
                }
            }
        }
    }
}

