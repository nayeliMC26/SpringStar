//
//  Spring Mesh Builder.swift
//  SpringStar
//
//  Created by Seth & Jelly on 9/29/25.
//

import RealityKit
import simd
// simd is single instruct multiple data, basically makes vector math easier/possible

public struct SpringMeshBuilder {
    public init() {}

    public func buildHelixMesh(
        radius: Float,
        height: Float,
        coils: Int,
        tubeRadius: Float = 0.005,
        tubeSegments: Int = 24,
        segmentsPerCoil: Int = 32,
        anchoredTop: Bool = true
    ) throws -> MeshResource {
        let totalSegments = max(1, coils * segmentsPerCoil)
        let pitch = height / Float(max(1, coils))
        let twoPi = Float.pi * 2

        var centers = [SIMD3<Float>]()
        var tangents = [SIMD3<Float>]()

        for i in 0...totalSegments {
            let t = Float(i) / Float(segmentsPerCoil) * twoPi
            let x = radius * cos(t)
            let z = radius * sin(t)
            let y: Float
            if anchoredTop {
                // Anchor at top (y = 0), helix extends downward to -height
                //TODO: May need to adjust for pushing up on the spring which is another way the simulation might start
                y = -pitch * t / twoPi
            } else {
                // Centered variant
                y = pitch * t / twoPi - height / 2
            }
            centers.append(SIMD3<Float>(x, y, z))

            let dx = -radius * sin(t)
            let dz = radius * cos(t)
            let dy = pitch / twoPi
            tangents.append(normalize(SIMD3<Float>(dx, dy, dz)))
        }

        var normals = [SIMD3<Float>]()
        var binormals = [SIMD3<Float>]()
        let arbitrary = SIMD3<Float>(0, 1, 0)
        for i in 0...totalSegments {
            let tangent = tangents[i]
            var normal = simd_cross(tangent, arbitrary)
            if simd_length(normal) < 0.001 {
                normal = simd_cross(tangent, SIMD3<Float>(1, 0, 0))
            }
            normal = normalize(normal)
            let binormal = normalize(simd_cross(tangent, normal))
            normals.append(normal)
            binormals.append(binormal)
        }

        var vertices = [SIMD3<Float>]()
        var normalsForVertices = [SIMD3<Float>]()
        var uvs = [SIMD2<Float>]()
        for i in 0...totalSegments {
            for j in 0..<tubeSegments {
                let theta = Float(j) / Float(tubeSegments) * twoPi
                let circlePos = normals[i] * cos(theta) * tubeRadius + binormals[i] * sin(theta) * tubeRadius
                let vertexPos = centers[i] + circlePos
                vertices.append(vertexPos)
                normalsForVertices.append(normalize(circlePos))
                let u = Float(j) / Float(tubeSegments)
                let v = Float(i) / Float(totalSegments)
                uvs.append(SIMD2<Float>(u, v))
            }
        }

        var indices = [UInt32]()
        for i in 0..<totalSegments {
            for j in 0..<tubeSegments {
                let nextJ = (j + 1) % tubeSegments
                let i0 = UInt32(i * tubeSegments + j)
                let i1 = UInt32((i + 1) * tubeSegments + j)
                let i2 = UInt32((i + 1) * tubeSegments + nextJ)
                let i3 = UInt32(i * tubeSegments + nextJ)
                indices.append(contentsOf: [i0, i1, i2])
                indices.append(contentsOf: [i0, i2, i3])
            }
        }

        var descriptor = MeshDescriptor()
        descriptor.positions = MeshBuffers.Positions(vertices)
        descriptor.normals = MeshBuffers.Normals(normalsForVertices)
        descriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)
        descriptor.primitives = .triangles(indices)
        return try MeshResource.generate(from: [descriptor])
    }
}

