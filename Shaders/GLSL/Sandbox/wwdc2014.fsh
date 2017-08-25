#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float field(vec2 p) {
    float bd = 0.0;
    bd += smoothstep(1.0, 0.65, length(p - vec2(-0.5, -1.2)));
    bd += smoothstep(1.0, 0.65, length(p - vec2( 0.5, -1.2)));
    bd = max(0.0, 1.0 - bd);
    
    float ld;
    ld = length(p - vec2(-0.6, 1.1)) - 1.2;
    ld = max(ld, length(p - vec2(1.4, 0.1)) - 1.2);
    ld = smoothstep(0.0, 0.3, ld);
    
    return min(ld, bd);
}

float nlength(vec2 p, float n) {
    return pow(dot(vec2(1.0), pow(p, vec2(n))), 1.0 / n);
}

void main(void) {
    vec2 p = (gl_FragCoord.xy * 2.0 - resolution) / resolution.x;
    
    vec3 rgb;
    rgb = cos((vec3(0.3333, 0.0, 0.6667) + (p.x + 1.0) * 0.5 + 0.02) * 6.2831853 * 0.8) * 0.4 + 0.6;
    
    float tiles = 16.0;
    vec2 tp = floor(p * tiles) / tiles;
    
    float r = field(tp) * 0.9;
    r *= (sin((tp.x + sin(tp.y * 4.0 + time * 1.3)) * 2.0 + time) * 0.1 + 0.9);
    
    float l = nlength(fract(p * tiles) * 2.0 - 1.0, 8.0);
    rgb = mix(rgb, vec3(1.0), clamp(smoothstep(r-0.05, r, l), 0.0, 1.0));
    
    gl_FragColor = vec4(rgb, 1.0);
}
