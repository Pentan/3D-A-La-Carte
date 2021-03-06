precision mediump float;

#extension GL_OES_standard_derivatives : enable
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

vec3 rotX(vec3 p, float a) {
    vec2 sc = sin(vec2(a, a + 1.57079632));
    return vec3(
        p.x,
        p.y * sc.y + p.z * sc.x,
        p.y * -sc.x + p.z * sc.y
    );
}

vec3 rotY(vec3 p, float a) {
    vec2 sc = sin(vec2(a, a + 1.57079632));
    return vec3(
        p.x * sc.y + p.z * sc.x,
        p.y,
        p.x * sc.x - p.z * sc.y
    );
}

vec3 rotZ(vec3 p, float a) {
    vec2 sc = sin(vec2(a, a + 1.57079632));
    return vec3(
        p.x * sc.y + p.y * sc.x,
        p.x * -sc.x + p.y * sc.y,
        p.z
    );
}

vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.xx+p3.yz)*p3.zy);
}

vec2 noise(vec2 p) {
    const vec2 k = vec2(0.0, 1.0);
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 h00 = hash22(i + k.xx);
    vec2 h01 = hash22(i + k.xy);
    vec2 h10 = hash22(i + k.yx);
    vec2 h11 = hash22(i + k.yy);
    // f = f * f * (3.0 - 2.0 * f);
    f = f * f * f * (f * (6.0 * f - 15.0) + 10.0);
    return mix(mix(h00, h10, f.x), mix(h01, h11, f.x), f.y);
}

vec2 fbm(vec2 p) {
    mat2 m = mat2(-0.73736887, 0.67549029, 0.67549029, 0.73736887);
    vec2 f = vec2(0.0);
    float s = 0.5;
    for(int i = 0; i < 4; i++) {
        f += noise(p) * s;
        s *= 0.5;
        p = (p + vec2(0.03, 0.07)) * 2.01 * m;
    }
    return f;
}

//
float sdEllipsoid(vec2 p, vec2 r) {
    float k0 = length(p / r);
    float k1 = length(p / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

float sdCapsule(vec2 p, vec2 a, vec2 b, float r) {
    vec2 d = b - a;
    float l = length(d);
    d = normalize(d);
    vec2 v = p - a;
    float h = min(l, max(0.0, dot(v, d)));
    return length(v - d * h) - r;
}

float smin(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0);
    return min(a, b) - h * h * 0.25 / k;
}

vec2 leaf(vec2 p) {
    float d;
    p.x = abs(p.x);
    float d0 = max(sdEllipsoid(p, vec2(0.85, 1.0)), -p.y);
    float d1 = sdCapsule(p, vec2(0.0, 0.7), vec2(0.0, 1.0), 0.02);
    float d2 = sdEllipsoid(p - vec2(0.8, 0.0), vec2(0.78, 0.3));
    float d4 = sdCapsule(p, vec2(0.0, 0.1), vec2(0.0, -0.8), 0.02);

    d = -smin(-d0, d1, 0.15);
    d = -smin(-d, d2, 0.1);
    d = smin(d, d4, 0.05);

    float r = length(p);
    float th = asin(p.y / r);
    float h = (p.y < 0.0)? 1.0 : abs(sin(th * 60.0));
    h = max(h, 1.0 - pow(length(p) * 2.0, 3.0));

    return vec2(d, h);
}

vec3 h2c(float h) {
    const vec3 c0 = vec3(0.18, 0.96, 0.93);
    const vec3 c1 = vec3(0.14, 0.96, 0.98);
    vec3 c = mix(c0, c1, h);
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float roadh(vec2 p, inout vec4 m) {
    const float xs = 2.0;
    p *= vec2(1.0/xs, 1.0);
    vec2 ip = floor(p);
    vec2 ap = p + vec2(ip.y * 0.5, 0.0);
    vec2 fp = fract(ap);
    float d;

    fp = min(fp, 1.0 - fp) * 2.0;
    d = min(1.0, min(fp.x * xs, fp.y) * 8.0);

    vec2 n = fbm(p * 8.0);
    float d0 = n.x;
    float d1 = 1.0 - min(1.0, n.y * 3.5);

    d -= d0 * 0.2;
    d -= d1 * 0.4;

    if(m.x > 0.0) {
        vec2 iap = floor(ap);
        m.xy = hash22(iap);
        m.yz = iap;
    }
    return d;
}

vec3 road(vec2 p) {
    const vec2 eps = vec2(1e-2, 0.0);
    vec4 m;

    // normal
    m = vec4(0.0);
    vec3 n;
    n.x = roadh(p - eps.xy, m) - roadh(p + eps.xy, m);
    n.y = roadh(p - eps.yx, m) - roadh(p + eps.yx, m);
    n.z = eps.x * 3.0;
    n = normalize(n);

    // main
    m = vec4(1.0);
    float d = roadh(p, m);

    float ao = 1.0 - pow(max(0.0, 1.0 - d), 8.0);
    ao = mix(0.6, 1.0, max(0.0, ao));

    vec3 l = normalize(vec3(0.5, 0.7, 2.0));
    float dfs = dot(l, n);
    dfs = mix(0.8, 1.0, pow(clamp(dfs * 3.0, 0.0, 1.0), 4.0));

    vec3 col;

    const vec3 c0 = vec3(0.74, 0.72, 0.49);
    const vec3 c1 = vec3(0.66, 0.64, 0.42);
    col = mix(c0, c1, m.x);

    vec2 f = fbm(p * 2.0);
    //col = f.xxx;
    const vec3 c2 = vec3(0.73, 0.68, 0.44);
    col = mix(col, c2, f.x);

    // lit
    col *= dfs * ao;

    return col;
}

vec3 spreadleaf(vec2 p, float R) {
    const int N = 2;
    vec2 ip = floor(p);
    float h = -1.0;
    vec3 col = road(p);
    vec2 f = fbm(p * 4.0);

    for(int j = -N; j <= N; j++) {
        float y = float(j);
        for(int i = -N; i <= N; i++) {
            float x = float(i);
            vec2 cp = ip + vec2(x, y);
            vec2 ch = hash22(cp);
            cp += (ch * 2.0 - 1.0) * R;

            vec2 lp = cp - p + (f * 2.0 - 1.0) * 0.05;
            ch = hash22(ch * 123.4567);
            float angl = ch.x * 6.28318530;
            lp = rotZ(vec3(lp, 0.0), angl).xy;

            vec2 lfd = leaf(lp * 1.2);
            col = mix(col, col * vec3(0.4), smoothstep(0.04, -0.02, lfd.x)); // shadow
            vec3 tint = mix(vec3(0.75, 0.7, 0.6), vec3(1.0), lfd.y);
            col = mix(col, h2c(ch.y) * tint, smoothstep(0.0, -0.01, lfd.x)); // leaf
        }
    }

    return col;
}

vec3 render(vec2 sp) {
    vec3 op = vec3(0.0, 0.0, 4.0);
    vec3 dv = normalize(vec3(sp, -2.0));

    vec3 angle = vec3(
        0.8 + sin(time * 1.2) * 0.02,
        sin(time * 1.5) * 0.05,
        0.0
    );
    op = rotZ(rotY(rotX(op, angle.x), angle.y), angle.z);
    dv = rotZ(rotY(rotX(dv, angle.x), angle.y), angle.z);
    op += vec3(0.0, 1.0 + abs(sin(time * 6.0)) * 0.06, 0.0);

    vec3 gp = dv * op.y / dv.y;
    vec3 col;
    col = spreadleaf(gp.xz * 2.0 + vec2(0.0, -time), 0.5);

    vec3 vgn = exp(-pow(length(sp), 2.0) * vec3(0.5, 0.6, 1.0) * 0.2);
    // col *= vgn;
    col -= 1.0 - vgn;

    return col;
}

void main() {
    vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);
    vec3 c = render(p);
    c = pow(clamp(c, 0.0, 1.0), vec3(1.0/1.8));
    gl_FragColor = vec4(c, 1.0);
}
