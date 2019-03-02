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
    const vec2 SIZE = vec2(0.75, 1.0);
    const float LINE_W = 0.01;

    vec2 uv = gl_FragCoord.xy / min(resolution.x, resolution.y);
    vec2 p = mod(uv * SCALE, SIZE) * 2.0 - SIZE;
    p = abs(p);

    float d0 = dot(normalize(SIZE.yx), (p - vec2(SIZE.x, 0.0)));
    d0 *= 0.5;
    float d1 = abs(dot(normalize(vec2(-SIZE.y, SIZE.x)), p));
    d1 *= 0.5;

    vec3 rgb = vec3(0.0);
    // rgb.xy = p;
    // rgb.xy = ap;
    // float d;
    // d = d0;
    // d = d1;
    // rgb = vec3(-d, d, exp(-d*d*10000.0));

    rgb = mix(vec3(0.2), vec3(0.8), edgeweight(d0));
    rgb = mix(vec3(0.6), rgb, edgeweight(d1 - LINE_W));

    gl_FragColor = vec4(rgb, 1.0);
}
