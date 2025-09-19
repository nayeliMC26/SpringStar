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

}
