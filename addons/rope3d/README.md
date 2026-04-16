# Rope3D for Godot 4
A highly stable, mathematically robust 3D rope and cable simulation plugin for Godot 4.

Built on an advanced Position-Based Dynamics (XPBD-style) algorithmic approach, `Rope3D` guarantees completely gapless, inelastic rope behavior using custom bidirectional Verlet solvers designed to out-perform standard Godot `RigidBody3D` chains.

## Features
- **Perfectly Inelastic:** Employs heavily constrained bidirectional Gauss-Seidel iterations to ensure 0cm gaps or mathematically impossible stretching.
- **Dynamic End Anchors:** The rope naturally simulates tension towards dynamic player/world anchors without destroying the rest-length solver, generating beautifully taut cables when pulled.
- **Smart Path Generation:** Uses native Godot `CSGPolygon3D` over a dynamic `Curve3D` to cleanly interpolate curves over rigidbodies.
- **Performance Focused:** Fully eliminates array-allocation overhead inside physics solver loops. Custom simulated collision exemptions avoid "jitter" at anchor joints.

## Usage
1. Add a `Rope3D` node to your scene.
2. Edit its internal `Curve3D` path to establish the default string shape and resting length.
3. (Optional) Provide an `attachment_start` and `attachment_end` `Node3D`. The rope will physically hook to these.

## Signals
- **`anchor_distanced(offset: Vector3)`:** Emitted whenever the physics string cannot mathematically reach the assigned anchor. Crucial for triggering gameplay mechanics (such as camera shake or weapon kick) precisely mapped to over-stretch tension!
