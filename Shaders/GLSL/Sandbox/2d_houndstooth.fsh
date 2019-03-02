precision mediump float;

//#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float edgeweight(float t) {
    const float AA = 0.001;
    return smoothstep(-AA, AA, t);
}

void main() {
    const float SCALE = 4.0;
    vec2 uv = gl_FragCoord.xy / min(resolution.x, resolution.y);
    // (-1,1) = x2
    vec2 p = (fract(uv * SCALE) - 0.5) * 2.0;

    // float d;
    // if(p.x < p.y) {
    //     p.xy = p.yx;
    // }
    // d = length(p - vec2(0.2, -0.2)) - 0.25;
    // if(p.x < 0.0) {
    //     d = min(-p.x, 1.0 + p.y);
    // } else if(p.y > 0.0) {
    //     d = max(-p.y, p.x - 1.0);
    // } else {
    //     const float ISQRT2 = 0.70710678;
    //     float dn = dot(vec2(1.0, -1.0), p);
    //     d = dn - 1.0;
    //     d = max(d, 0.5 - dn);
    //     d = min(d, 1.5 - dn);
    // }

    // Distance from diagonal (0,0),(1,1)
    vec2 p1 = (p.x < p.y)? p.yx : p.xy;
    const float ISQRT2 = 0.70710678;
    float dn = dot(vec2(1.0, -1.0), p1);
    float dn00 = dn * ISQRT2;
    float dn05 = (dn - 0.5) * ISQRT2;
    float dn10 = (dn - 1.0) * ISQRT2;
    float dn15 = (dn - 1.5) * ISQRT2;

    // Shapes
    float d0 = max(p1.x, -p1.y) - 0.5;
    float d1 = max(abs(p1.y) - 0.5, dn05);
    float d2 = max(max(-dn05, dn10), p1.x - 0.5);
    float d3 = max(-dn10, -0.5 - p1.y);
    float d4 = max(-dn15, p1.x - 0.5);
    float d5 = -(p1.x + 0.5);

    float d;
    // d = d0;
    // d = d1;
    // d = d2;
    // d = d3;
    // d = d4;
    d = min(d0, d1);
    d = min(d, d2);
    d = min(d, d3);
    d = min(d, d4);
    d = max(d, d5);

    // make x1
    d *= 0.5;

    vec3 rgb = vec3(0.0);
    // rgb.xy = p;
    // rgb.xy = p0;
    // rgb = vec3(-d, d, exp(-d*d*10000.0));
    rgb = mix(vec3(0.2), vec3(0.8), edgeweight(d));

    gl_FragColor = vec4(rgb, 1.0);
}
