import RealityKit
import simd

/// Generates a tubular **helix** mesh (a “spring”) coiling around the Y-axis,
/// using a centerline curve + local frames (normal/binormal) to sweep a circle.
///
/// PARAMETERS (units in meters, radians):
/// - radius:       distance from Y-axis to the helix centerline (how “wide” the spring is)
/// - pitch:        vertical rise per full turn (2π radians)
/// - coils:        number of turns (full 360° rotations)
/// - tubeRadius:   thickness of the wire you sweep along the helix
/// - tubeSegments: number of vertices around the wire’s circular cross section
/// - segmentsPerCoil: number of rings (samples along the curve) per single coil
///
/// RETURNS:
/// - A RealityKit MeshResource you can place in a ModelEntity.
///
/// NOTES:
/// - This version picks the per-ring frame (normal/binormal) using an arbitrary
///   reference vector; it’s simple and works, but can introduce slow twisting
///   along the length. For production, consider **parallel transport** frames
///   to minimize twist.
/// - This function is `throws` because `MeshResource.generate(from:)` can throw.
func generateHelixMesh(
    radius: Float = 0.05,
    pitch: Float = 0.05,
    coils: Int = 8,
    tubeRadius: Float = 0.005,
    tubeSegments: Int = 16,
    segmentsPerCoil: Int = 48
) throws -> MeshResource {

    // ------------------------------------------------------------------------
    // 0) CONSTANTS & DERIVED COUNTS
    // ------------------------------------------------------------------------

    let twoPi = Float.pi * 2                                  // 2π, used often
    let totalSegments = coils * segmentsPerCoil               // total rings along the helix
    let totalTurns = Float(coils)                              // same as coils but as Float
    let height = pitch * totalTurns                            // total helix height = pitch * turns

    // Storage for per-ring data along the centerline:
    // centers  : positions of the helix spine at each ring i
    // tangents : unit direction of the spine at each ring i (for frame building)
    var centers = [SIMD3<Float>]()
    var tangents = [SIMD3<Float>]()

    centers.reserveCapacity(totalSegments + 1) // +1 because we sample inclusive end
    tangents.reserveCapacity(totalSegments + 1)

    // ------------------------------------------------------------------------
    // 1) SAMPLE THE HELIX CENTERLINE AND TANGENTS (SPINE OF THE TUBE)
    // ------------------------------------------------------------------------
    // We sample at (totalSegments + 1) rings so the last ring can stitch indices.
    // Parameterization:
    //   θ_i = (i / segmentsPerCoil) * 2π
    //   (x, z) = (r cos θ, r sin θ)
    //   y      = (pitch per turn) * (θ / 2π) - height/2   // centered vertically
    for i in 0...totalSegments {
        // Angular parameter θ; each segmentsPerCoil steps advances one full circle.
        let t = Float(i) / Float(segmentsPerCoil) * twoPi

        // Helix parametric position (coils around Y-axis)
        let x = radius * cos(t)
        let z = radius * sin(t)
        let y = pitch * t / twoPi - height / 2   // center vertically by subtracting H/2

        centers.append(SIMD3<Float>(x, y, z))

        // Tangent is the derivative of c(θ):
        //   d/dθ [r cos θ, (p/2π) θ, r sin θ] = [-r sin θ, p/2π, r cos θ]
        // Normalize so it’s a unit direction.
        let dx = -radius * sin(t)
        let dz =  radius * cos(t)
        let dy =  pitch / twoPi

        let tangent = normalize(SIMD3<Float>(dx, dy, dz))
        tangents.append(tangent)
    }

    // ------------------------------------------------------------------------
    // 2) BUILD A LOCAL ORTHONORMAL FRAME PER RING: (T, N, B)
    // ------------------------------------------------------------------------
    // For each ring i, we want two perpendicular directions (N, B) orthogonal to T
    // to define a local "circle plane" where we place the tube’s cross-section.
    // This version chooses N via cross(T, arbitraryUp) and fixes near-degenerate cases.
    // Then B = T × N. Both are normalized to keep the frame orthonormal.

    var normals   = [SIMD3<Float>]()
    var binormals = [SIMD3<Float>]()

    normals.reserveCapacity(totalSegments + 1)
    binormals.reserveCapacity(totalSegments + 1)

    // A reference vector not parallel to most tangents. Y-up is convenient since
    // the helix winds around Y; but near vertical tangents, we switch to X.
    let arbitrary = SIMD3<Float>(0, 1, 0)

    for i in 0...totalSegments {
        let tangent = tangents[i]

        // Candidate normal as N = normalize(T × arbitrary).
        // If T is nearly parallel to 'arbitrary', the cross-product is tiny;
        // in that case use a different reference (the X axis) to avoid near-zero.
        var normal = simd_cross(tangent, arbitrary)
        if simd_length(normal) < 0.001 {
            normal = simd_cross(tangent, SIMD3<Float>(1, 0, 0))
        }
        normal = normalize(normal)

        // Binormal completes the right-handed frame: B = normalize(T × N)
        let binormal = normalize(simd_cross(tangent, normal))

        normals.append(normal)
        binormals.append(binormal)
    }

    // ------------------------------------------------------------------------
    // 3) SWEEP A CIRCLE AROUND EACH RING TO CREATE VERTICES
    // ------------------------------------------------------------------------
    // For each ring i (position centers[i], frame (N,B)), we place 'tubeSegments'
    // points around a circle of radius 'tubeRadius' in the plane spanned by N and B.
    //
    // vertex(i, j) = center[i] + tubeRadius * ( cosθ_j * N[i] + sinθ_j * B[i] )
    // normal(i, j) =           ( cosθ_j * N[i] + sinθ_j * B[i] )  (unit outward)
    //
    // UVs:
    //   u = j / tubeSegments   (wraps around tube)
    //   v = i / totalSegments  (goes along helix length)
    var vertices = [SIMD3<Float>]()
    var normalsForVertices = [SIMD3<Float>]()
    var uvs = [SIMD2<Float>]()

    // Pre-reserve arrays for performance (avoid repeated reallocations)
    vertices.reserveCapacity( (totalSegments + 1) * tubeSegments )
    normalsForVertices.reserveCapacity( (totalSegments + 1) * tubeSegments )
    uvs.reserveCapacity( (totalSegments + 1) * tubeSegments )

    for i in 0...totalSegments {
        let N = normals[i]
        let B = binormals[i]

        for j in 0..<tubeSegments {
            // Angle around the cross-section circle for this vertex
            let theta = Float(j) / Float(tubeSegments) * twoPi

            // Position offset in the ring plane (N,B)
            // circlePos has length 'tubeRadius' and points outward from center.
            let circlePos = N * cos(theta) * tubeRadius
                          + B * sin(theta) * tubeRadius

            // World-space vertex = centerline point + ring offset
            let vertexPos = centers[i] + circlePos
            vertices.append(vertexPos)

            // Outward normal is just the direction of the circle offset (unit)
            normalsForVertices.append(normalize(circlePos))

            // Simple cylindrical UVs:
            // u wraps around the tube circumference; v marches along helix length
            let u = Float(j) / Float(tubeSegments)     // [0, 1) around tube
            let v = Float(i) / Float(totalSegments)    // [0, 1] along length
            uvs.append(SIMD2<Float>(u, v))
        }
    }

    // ------------------------------------------------------------------------
    // 4) CONNECT VERTICES INTO TRIANGLES (INDEX BUFFER)
    // ------------------------------------------------------------------------
    // Each adjacent pair of rings (i, i+1) forms a strip of quads; each quad is
    // two triangles. The j index wraps modulo tubeSegments to close the tube.
    var indices = [UInt32]()
    indices.reserveCapacity(totalSegments * tubeSegments * 6) // 2 tris * 3 idx

    for i in 0..<totalSegments {            // connect ring i to ring i+1
        for j in 0..<tubeSegments {         // connect segment j to j+1 (wrap)
            let nextJ = (j + 1) % tubeSegments

            // Flattened vertex indices for current/next ring & segment
            let i0 = UInt32(i *    tubeSegments + j)
            let i1 = UInt32((i+1) * tubeSegments + j)
            let i2 = UInt32((i+1) * tubeSegments + nextJ)
            let i3 = UInt32(i *    tubeSegments + nextJ)

            // Two CCW triangles per quad: (i0, i1, i2) and (i0, i2, i3)
            indices.append(contentsOf: [i0, i1, i2])
            indices.append(contentsOf: [i0, i2, i3])
        }
    }

    // ------------------------------------------------------------------------
    // 5) PACK INTO A RealityKit MeshDescriptor AND BUILD THE MESH
    // ------------------------------------------------------------------------
    // MeshDescriptor is an intermediate that holds vertex attributes and the
    // primitive topology (triangles). RealityKit validates this and builds a
    // GPU-ready MeshResource (which can throw on invalid data).
    var descriptor = MeshDescriptor()

    // Positions: array-of-floats backed by SIMD3<Float>
    descriptor.positions = MeshBuffers.Positions(vertices)

    // Normals: per-vertex, same count/order as positions
    descriptor.normals = MeshBuffers.Normals(normalsForVertices)

    // UVs: 2D texture coordinates per vertex (optional but useful for materials)
    descriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)

    // Triangle primitives from our index list
    descriptor.primitives = .triangles(indices)

    // Build the final MeshResource. This can throw if the descriptor is malformed.
    return try MeshResource.generate(from: [descriptor])
}
