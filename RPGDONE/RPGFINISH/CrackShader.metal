#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_main(uint vertexID [[vertex_id]]) {
    float2 positions[3] = {
        float2(-1.0, -1.0),
        float2(3.0, -1.0),
        float2(-1.0, 3.0)
    };
    return float4(positions[vertexID], 0.0, 1.0);
}

fragment float4 fragment_crack(float4 position [[position]]) {
    float2 uv = position.xy;
    float crack = step(0.4, fract(sin(uv.x * 40.0 + uv.y * 60.0) * 1000.0));
    return mix(float4(1, 1, 1, 0.2), float4(0, 0, 0, 0.0), crack);
} 