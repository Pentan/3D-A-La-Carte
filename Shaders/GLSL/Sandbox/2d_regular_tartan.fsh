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
    const float LINE_W = 0.01;
    vec2 uv = gl_FragCoord.xy / min(resolution.x, resolution.y);
    vec2 p = fract(uv * SCALE);

    vec3 rgb = vec3(0.0);
    vec2 d;
    float t;

    d = abs(vec2(0.5) - p) - 0.25;
    t = (edgeweight(d.x) + edgeweight(d.y)) * 0.5;
    rgb = mix(vec3(0.2), vec3(0.4), t);
    
    d = abs(abs(vec2(0.5) - p) - 0.125) - 0.0125;
    // d = abs(abs(abs(vec2(0.5) - p) - 0.06125) - 0.06125) - 0.0125;
    t = (edgeweight(d.x) + edgeweight(d.y)) * 0.5;
    rgb = mix(vec3(0.8), rgb, t);

    gl_FragColor = vec4(rgb, 1.0);
}
