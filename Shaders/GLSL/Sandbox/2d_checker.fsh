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
    vec2 p = fract(uv * SCALE) * 2.0 - 1.0;
    // p = fract(p);

    vec2 ap = abs(abs(p) - 0.5);
    float d = 0.5 - max(ap.x, ap.y);
    d *= sign(p.x) * sign(p.y);
    d *= 0.5;

    vec3 rgb = vec3(0.0);
    // rgb.xy = p;
    // rgb.xy = ap;
    // rgb = vec3(-d, d, exp(-d*d*10000.0));
    rgb = mix(vec3(0.2), vec3(0.8), edgeweight(d));

    gl_FragColor = vec4(rgb, 1.0);
}
