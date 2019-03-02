precision mediump float;

//#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float distanceFromRect(vec2 p, vec2 s, float r) {
    vec2 hs = s * 0.5;
    vec2 ap = abs(p - hs);
    ap = hs - ap;
    return min(ap.x, ap.y);
}

float distanceFromTrimedRect(vec2 p, vec2 s, float r) {
    vec2 hs = s * 0.5;
    vec2 ap = abs(p - hs);
    vec2 rp = hs - ap;
    float td = dot(ap - (hs - vec2(r, 0.0)), vec2(-0.707106781));
    return min(td, min(rp.x, rp.y));
}

float distanceFromRoundRect(vec2 p, vec2 s, float r) {
    vec2 hs = s * 0.5;
    vec2 ap = abs(p - hs);
    vec2 cp = vec2(hs.x - r, hs.y - r);
    vec2 vac = ap - cp;

    float d0 = min(0.0, max(vac.x, vac.y));
    float d1 = length(max(vec2(0.0, 0.0), vac));

    return r - (d0 + d1);
}

const float EDGE_AA = 0.5;
float edgeweight(float t) {
    return smoothstep(-EDGE_AA, EDGE_AA, t);
}

vec3 distanceDbg(float d, float ex, float w) {
    return vec3(fract(-d / w), fract(d / w), exp(-d * d * ex));
}

// Sphere
// float dToHalfSphere(float d) {
//     float cd = 0.5 - clamp(d, 0.0, 1.0);
//     return sqrt(0.25 - cd * cd) * 2.0;
// }
float dToQuarterSphere(float d) {
    float cd = 1.0 - clamp(d, 0.0, 1.0);
    return sqrt(1.0 - cd * cd);
}

// Palabola
// float dToPalabla(float d) {
//     float cd = clamp(d, 0.0, 1.0);
//     return cd * (cd - 1.0) * -4.0;
// }
float dToHalfPalabla(float d) {
    float cd = 1.0 - clamp(d, 0.0, 1.0);
    return 1.0 - cd * cd;
}

// Pow
// float dToPow(float d, float x) {
//     float cd = abs(1.0 - clamp(d, 0.0, 1.0) * 2.0);
//     return 1.0 - pow(cd, x);
// }
float dToHalfPow(float d, float x) {
    float cd = 1.0 - clamp(d, 0.0, 1.0);
    return 1.0 - pow(cd, x);
}

//
float distanceFromShape(vec2 p, vec2 s, float r) {
    // return distanceFromRect(p, s, r);
    return distanceFromRoundRect(p, s, r);
    // return distanceFromTrimedRect(p, s, r);
}

const vec2 MARGIN = vec2(16.0, 140.0);
const float SCALE = 320.0;
const float RADIUS = 32.0;
const float BORDER_W = 8.0;
const float SHADE_MIN = 0.5;

vec3 evalShading(float d) {
    vec3 shd;

    // Base
    shd.x = (d - BORDER_W) / (RADIUS - BORDER_W);
    shd.x = min(1.0, shd.x);
    shd.x = dToQuarterSphere(shd.x);
    // shd.x = dToHalfPalabla(shd.x);
    // shd.x = dToHalfPow(shd.x, 4.0);

    // Border
    shd.y = d / BORDER_W;
    shd.y = min(shd.y, 1.0 - shd.y) * 2.0;
    shd.y = min(1.0, shd.y);
    shd.y = dToQuarterSphere(shd.y);
    // shd.y = dToHalfPalabla(shd.y);
    // shd.y = dToHalfPow(shd.y, 4.0);

    // All
    shd.z = max(shd.x, shd.y);

    return shd;
}

float evalLighting(vec2 p, vec2 s, float r, float angle) {
    const float EPS = 1.0;
    const float BH = 0.5;

    vec2 dir = cos(vec2(angle, angle + 1.5707963)) * EPS;
    float d0 = distanceFromShape(p - dir, s, r);
    float d1 = distanceFromShape(p + dir, s, r);
    vec3 s0 = evalShading(d0);
    vec3 s1 = evalShading(d1);
    float h0 = max(s0.x, s0.y * BH);
    float h1 = max(s1.x, s1.y * BH);
    float g = (h1 - h0) / (EPS * 2.0);
    // float ao = 1.0;// - pow(1.0 - ((s1.z + s0.z) * 0.5), 1.0);
    // float ao = smoothstep(0.0, 0.5, ((s1.z + s0.z) * 0.5));
    // float ao = 1.0-abs(g);
    // return ao;
    float l;
    l = g;
    // l *= ao;

    return l;
}

void main() {

    vec2 uv = gl_FragCoord.xy / min(resolution.x, resolution.y) * SCALE;
    uv -= MARGIN;
    vec2 size = resolution / min(resolution.x, resolution.y) * SCALE;
    size -= (MARGIN * 2.0);

    float d;
    d = distanceFromShape(uv, size, RADIUS);
    d -= EDGE_AA;
    // d = length(uv - size*0.5) - 100.0;

    vec3 rgb = vec3(0.0);
    // rgb.xy = p;
    // rgb.xy = ap;
    // rgb = vec3(-d, d, exp(-d*d*100.0));
    // rgb = vec3(min(1.0, -d)*0.5, min(1.0, d)*0.5, fract(d / 12.0));
    // rgb = mix(vec3(0.2), vec3(0.8), edgeweight(d));
    // gl_FragColor = vec4(rgb, 1.0);
    // return;

    vec3 basecol = vec3(0.8);
    vec3 bordercol = vec3(0.5);
    vec3 bgcol = vec3(0.8, 0.2, 0.8);

#if 0
    // Shading
    vec3 shd = evalShading(d);
    // basecol = distanceDbg(shd.x, 4000.0, 1.0);
    basecol = vec3(shd.x);
    // basecol *= mix(SHADE_MIN, 1.0, shd.x);

    // bordercol = distanceDbg(shd.y, 4000.0, 1.0);
    bordercol = vec3(shd.y);
    // bordercol *= mix(SHADE_MIN, 1.0, shd.y);

    //+++++
    rgb = vec3(shd.z);
    //+++++
#endif

#if 1
    // Lighting
    float lit = evalLighting(uv, size, RADIUS, time);

    //+++++
    // rgb = distanceDbg(lit, 1000.0, 1.0);
    // rgb = vec3(lit + 0.5);
    lit *= 4.0;
    rgb = vec3(lit);
    vec3 darkcol = vec3(0.2);
    vec3 midcol = vec3(1.0);
    vec3 highcol = vec3(1.2);
    vec3 litcol;
    litcol = mix(midcol, highcol, lit);
    litcol = mix(litcol, darkcol, -lit);
    rgb = litcol;
    basecol.rgb *= litcol;
    bordercol.rgb *= litcol;
    //+++++
#endif

    float t;
#if 1
    t = edgeweight(d - BORDER_W);
    rgb = mix(bordercol, basecol, t);
#endif

    t = edgeweight(d);
    rgb = mix(bgcol, rgb, t);

    gl_FragColor = vec4(rgb, 1.0);
}
