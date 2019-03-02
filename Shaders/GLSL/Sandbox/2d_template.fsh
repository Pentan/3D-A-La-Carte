precision mediump float;

//#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

// vec2 rot(vec2 p, float a) {
//     vec2 sc = cos(vec2(a, a + 1.5707963));
//     return vec2(
//         p.x * sc.x - p.y * sc.y,
//         p.x * sc.y + p.y * sc.x
//     );
// }

float edgeweight(float t) {
    const float AA = 0.001;
    return smoothstep(-AA, AA, t);
}

void main() {
    const float SCALE = 4.0;
    vec2 uv = gl_FragCoord.xy / min(resolution.x, resolution.y);
    vec2 p = fract(uv * SCALE) - 0.5;

    float d = length(p) - 0.25;

    vec3 rgb = vec3(0.0);
    // rgb.xy = p;
    // rgb.xy = ap;
    // rgb = vec3(-d, d, exp(-d*d*10000.0));
    rgb = mix(vec3(0.2), vec3(0.8), edgeweight(d));

    gl_FragColor = vec4(rgb, 1.0);
}
