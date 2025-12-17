//
//  ProcSpringRenderer.swift
//  SpringStar
//
//  Created by Jelly on 9/29/25.

//  A procedural spring renderer for RealityKit.
//  This class dynamically generates and updates a 3D helical spring mesh.
// Assitance from Copilot for Mass rendering

import RealityKit
import UIKit
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
    
    /// The mass entity attached to the bottom of the spring (if created).
    private var massEntity: ModelEntity?

    /// The original mesh height used when building the spring (used to position the mass).
    private let meshHeight: Float = 0.5

    /// Visual radius for the attached mass.
    private let massRadius: Float = 0.06

    /// Current visual scale factor derived from the mass parameter (cube-root scaling).
    private var currentMassScale: Float = 1.0
    
    /// A constant scaling factor for the mass
    private let massScaleFactor: Float = 0.45


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

            // Create and attach a mass at the bottom of the spring.
            // Position is set in the spring's local space (mesh built from y=0 down to -meshHeight).
            let massMesh = MeshResource.generateSphere(radius: massRadius)
            let massUIColor = UIColor(red: 252.0/255.0, green: 234.0/255.0, blue: 63.0/255.0, alpha: 1.0)
            let massMaterial = SimpleMaterial(color: massUIColor, isMetallic: false)
            let mass = ModelEntity(mesh: massMesh, materials: [massMaterial])
            // Place at bottom of the unscaled mesh
            mass.position = [0, -meshHeight, 0]
            // Apply initial scale: incorporate currentMassScale and inverse parent scaling
            let parentScale = entity.scale
            let inv = SIMD3<Float>(parentScale.x != 0 ? 1.0 / parentScale.x : 1.0,
                                   parentScale.y != 0 ? 1.0 / parentScale.y : 1.0,
                                   parentScale.z != 0 ? 1.0 / parentScale.z : 1.0)
            mass.scale = SIMD3<Float>(repeating: currentMassScale * massScaleFactor) * inv
            entity.addChild(mass)
            massEntity = mass
        }
        return modelEntity
    }

    /// Scales the spring along its vertical axis to match a target height.
    /// The mesh is modeled with its top at y = 0, so scaling keeps the top anchored.
    /// - Parameters:
    ///   - height: Desired total spring height (rest length + displacement).
    ///   - restLength: Base rest length used for normalization.
    public func updateHeight(_ height: Float, restLength: Float) {
        guard let entity = modelEntity else { return }
        let safeRest = max(restLength, 0.001)
        let ratio = max(height, 0.01) / safeRest
        let xzScale = entity.scale
        entity.scale = SIMD3<Float>(xzScale.x, scaleFactor * ratio, xzScale.z)

        // Keep the attached mass visually constant size by inverse-scaling it
        if let mass = massEntity {
            let parentScale = entity.scale
            // avoid division by zero
            let inv = SIMD3<Float>(parentScale.x != 0 ? 1.0 / parentScale.x : 1.0,
                                   parentScale.y != 0 ? 1.0 / parentScale.y : 1.0,
                                   parentScale.z != 0 ? 1.0 / parentScale.z : 1.0)
            // Apply mass scale (cube-root based) and inverse parent scale
            mass.scale = SIMD3<Float>(repeating: currentMassScale * massScaleFactor) * inv
            // Ensure mass remains positioned at the bottom of the mesh (local coords)
            mass.position = [0, -meshHeight, 0]
        }
    }

    /// Update the visual size of the attached mass according to the physical mass value.
    /// Uses cube-root scaling so volume scales with mass.
    public func updateMass(_ mass: Float) {
        // Avoid negative/zero
        let m = max(mass, 1e-6)
        currentMassScale = pow(m, 1.0 / 3.0)
        // If the model exists, update the mass entity scale to reflect currentMassScale
        guard let entity = modelEntity, let massEntity = massEntity else { return }
        let parentScale = entity.scale
        let inv = SIMD3<Float>(parentScale.x != 0 ? 1.0 / parentScale.x : 1.0,
                               parentScale.y != 0 ? 1.0 / parentScale.y : 1.0,
                               parentScale.z != 0 ? 1.0 / parentScale.z : 1.0)
        massEntity.scale = SIMD3<Float>(repeating: currentMassScale * massScaleFactor) * inv
    }
}
