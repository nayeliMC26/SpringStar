//
//  Sandbox.swift
//  SpringStar
//
//  Created by Villa, Nayeli on 9/19/25.
//

import RealityKit
import simd
import SwiftUI

struct Cylinder {
    var height : Float
    var radius : Float
    
    // V = h * pi * r^2
    
    init(height: Float, radius: Float) {
        
        self.height = height
        self.radius = radius
        
    }
    
    var volume : Float {
        height * Float.pi * pow(radius, 2)
    }
    
    var lateralSurfaceArea : Float {
        2 * Float.pi * radius * height
    }
    
    var totalSurfaceArea : Float {
        (2 * Float.pi * radius * height) + (2 * Float.pi * pow(radius, 2))
    }
    
    func Cylinder() throws -> MeshResource {
        .generateCylinder(height: height,
                              radius: radius
        )
    }
}

struct Helix {
    // This is the radius of the circles formed by the coil
    var radius : Float
    // Distance between each of the coils
    var pitch : Float
    // This is the number of full turns in helix (related to hegiht)
    var coils : Int
    // This is the radius of the tube mesh actually forming the helix
    var tubeRadius : Float
    // Each coil has some amount of segments so for example a very rigid cartoon like "spring" versus a smoother spring
    var tubeSegments : Int
    // 
    var segmentsPerCoil : Int
    
    init(radius: Float, pitch: Float, coils: Int, tubeRadius: Float, tubeSegments: Int, segmentsPerCoil: Int) {
        self.radius = radius
        self.pitch = pitch
        self.coils = coils
        self.tubeRadius = tubeRadius
        self.tubeSegments = tubeSegments
        self.segmentsPerCoil = segmentsPerCoil
        
        let totalSegments = coils * segmentsPerCoil
        for i in 0...totalSegments {
            let t = Float(i) / Float(segmentsPerCoil) * (Float.pi * 2)
            
            let x = radius * cos(t)
        }
    }

}

