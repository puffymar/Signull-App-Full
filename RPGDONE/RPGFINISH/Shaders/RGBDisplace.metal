#include <metal_stdlib>
using namespace metal;

// SwiftUI Shader: rgbDisplace(texture, time, amp)
[[ stitchable ]]
half4 rgbDisplace(
    float2 pos,
    half4  color,
    device half*   _unused        [[ buffer(0) ]],
    texture2d<half> tex           [[ texture(0) ]],
    sampler          s            [[ sampler(0) ]],
    float            time,
    float            amp
){
    float n1 = sin( (pos.x*0.012 + time*0.65) ) * cos( (pos.y*0.010 - time*0.58) );
    float n2 = sin( (pos.x*0.021 - time*0.45) ) * sin( (pos.y*0.018 + time*0.62) );
    float2 off = float2(n1, n2) * amp;

    half r = tex.sample(s, pos + off).r;
    half g = tex.sample(s, pos).g;
    half b = tex.sample(s, pos - off).b;
    return half4(r, g, b, 1.0h);
}


