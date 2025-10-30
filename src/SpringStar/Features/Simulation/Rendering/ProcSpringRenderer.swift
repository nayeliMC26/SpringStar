//
//  ProcSpringRenderer.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.

//  A procedural spring renderer for RealityKit.
//  This class dynamically generates and updates a 3D helical spring mesh.
//

import RealityKit
import simd

/// `ProcSpringRenderer` is responsible for creating and updating a 3D spring (helix) model procedurally.
public final class ProcSpringRenderer {
    
    /// The `ModelEntity` representing the spring in RealityKit.
    public private(set) var modelEntity: ModelEntity?
    
    /// Helper class responsible for constructing the actual mesh geometry of the spring.
    private let meshBuilder = SpringMeshBuilder()

    // MARK: - Configuration Properties
    
    /// The radius of the helix (distance from the spring’s center axis to the coil center).
    private let radius: Float
    
    /// The number of coils (turns) in the spring.
    private let coils: Int
    
    /// The radius of the tube forming the spring wire.
    private let tubeRadius: Float
    
    /// A constant scaling factor applied to the final spring model.
    private let scaleFactor: Float = 0.85

    // MARK: - Initialization
    
    /// Creates a new procedural spring renderer with given parameters.
    /// - Parameters:
    ///   - radius: The base radius of the helix.
    ///   - coils: Number of turns in the spring (minimum 1).
    ///   - tubeRadius: Radius of the wire forming the spring.
    public init(radius: Float = 0.1, coils: Int = 8, tubeRadius: Float = 0.005) {
        self.radius = radius
        self.coils = max(1, coils) // Ensure at least one coil
        self.tubeRadius = tubeRadius
    }

    // MARK: - Entity Creation
    
    /// Creates the spring entity if it doesn’t already exist.
    /// - Returns: The `ModelEntity` representing the spring.
    /// - Throws: An error if the mesh could not be built.
    public func makeEntityIfNeeded() throws -> ModelEntity? {
        // Only create the entity once
        if modelEntity == nil {
            
            // Build a procedural helical mesh using the mesh builder
            let mesh = try meshBuilder.buildHelixMesh(
                radius: radius,
                height: 0.5,              // Initial height of the spring
                coils: coils,
                tubeRadius: tubeRadius,
                tubeSegments: 28,         // Number of radial segments forming the tube
                segmentsPerCoil: 40,      // Number of subdivisions per coil for smoothness
                anchoredTop: true         // Keep the top of the spring anchored in place
            )

            // Create a simple material
            let material = SimpleMaterial(color: .gray, isMetallic: true)
            
            // Create the model entity using the mesh and material
            let entity = ModelEntity(mesh: mesh, materials: [material])
            
            // Set the entity’s transform
            entity.position = [0, 0, 0]
            entity.scale = [scaleFactor, scaleFactor, scaleFactor]
            
            // Store for later updates
            modelEntity = entity
        }
        return modelEntity
    }
}
