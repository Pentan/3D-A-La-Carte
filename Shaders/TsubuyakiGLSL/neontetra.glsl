precision highp float;
uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

#define PI 3.14159265358979

void main1()
{
    vec3 rgb;
    vec2 p = gl_FragCoord.xy / min(resolution.x, resolution.y) * 2.0 - 1.0;

    float rot = time;
    mat2 m = mat2(
        cos(rot), sin(rot),
        -sin(rot), cos(rot)
    );
    p *= m;

    p.y = abs(p.y);

    // triangle
    float d = -p.x;
    d = max(d, dot(vec2(0.5, 0.886), vec2(-1.0, 0.0) + p));
    // rgb = vec3(p, 0.0);
    // rgb = vec3(-d, exp(-d*d*1e5), d);
    rgb = vec3(1.0, 1.0, 0.5) * exp(-d*d*1e4);
    
    d = length(p);
    rgb += vec3(1.0, 0.4, 0.4) * exp(-d*d*20.) * 1.0;
    d = length(vec2(1.0, 0.0) - p);
    rgb += vec3(0.0, 0.4, 1.0) * exp(-d*d*20.) * 1.0;

    gl_FragColor=vec4(rgb,1);
}

vec3 neontetra(vec2 p, vec2 q, float a)
{
    mat2 m = mat2(
        cos(a), cos(a - PI * 0.5),
        cos(a + PI * 0.5), cos(a)
    );

    vec2 b = (p - q) * m / 64.0;
    b.y = abs(b.y);
    
    vec3 rgb;

    float d;
    d = max(-b.x, dot(vec2(0.5, 0.886), vec2(-1.0, 0.0) + b));
    rgb = vec3(1.0, 1.0, 0.5) * exp(-d*d*1e3);
    
    d = length(b);
    rgb += vec3(1.0, 0.4, 0.4) * exp(-d*d*10.) * 1.0;
    d = length(vec2(1.0, 0.0) - b);
    rgb += vec3(0.0, 0.4, 1.0) * exp(-d*d*10.) * 1.0;

    return rgb;
}

void main0(){
    vec3 rgb = vec3(gl_FragCoord.xy / resolution.xy, 0.0);

    vec2 p = gl_FragCoord.xy;

    rgb = vec3(0.0);
    for(float i = 0.0; i < 32.0; i+=1.0)
    {
        vec2 v = sin(2.4 * i + vec2(0.0, PI * 0.5)) * 0.1;
        vec4 q = vec4(v.xyxy * (vec2(0.0, 0.1) + time + 100.0).xxyy);
        q = fract(abs(q));
        q = min(q, 1.0 - q) * 2.0 * resolution.xyxy;

        vec2 s = q.zw - q.xy;
        // rgb += neontetra(p, q.xy, atan(s.y, s.x));

        mat2 m = mat2(cos(atan(s.y, s.x) + vec4(0.0, -PI * 0.5, PI * 0.5, 0.0)));

        vec2 b = (p - q.xy) * m / 64.0;
        b.y = abs(b.y);

        float d;
        d = max(-b.x, dot(vec2(0.5, 0.886), vec2(-1.0, 0.0) + b));
        rgb += vec3(1.0, 1.0, 0.5) * exp(-d*d*1e3);
        
        d = length(b);
        rgb += vec3(1.0, 0.4, 0.4) * exp(-d*d*10.) * 1.0;
        d = length(vec2(1.0, 0.0) - b);
        rgb += vec3(0.0, 0.4, 1.0) * exp(-d*d*10.) * 1.0;

    }

    gl_FragColor=vec4(rgb,1);
}

// golf!
#define e(d,x) exp(-d*d*x)
void main2(){
    vec4 o = vec4(0.0);
    vec2 b,p=gl_FragCoord.xy;
    for(float d,F=.5,N=64.,H=1.57,L=1.,Z=.0,i=Z;i<N;i+=L)
    {
        vec4 c=vec4(L,F,Z,Z),q=fract(abs(vec4(sin(2.4*i+vec2(Z,H)).xyxy*.1*(vec2(Z,.1)+time+1e2).xxyy)));
        q=min(q,L-q)*2.*resolution.xyxy;
        b=(p-q.xy)*mat2(cos(atan(q.w-q.y,q.z-q.x)+vec4(Z,-H,H,Z)))/N;
        b.y=abs(b.y);
        o+=c.xxyz*e(max(-b.x,dot(vec2(F,.886),vec2(-L,Z)+b)),1e3)
        +c.xyyx*e(length(b),10.)
        +c.zyxx*e(length(vec2(L,Z)-b),10.);
    }

    o.a = 1.0;
    gl_FragColor=o;
}

/* geeker(300)
#define e(d,x) exp(-d*d*x)
void main(){vec2 b,p=gl_FragCoord.xy;for(float d,F=.5,N=64.,H=1.57,L=1.,Z=.0,i=Z;i<N;i+=L){vec4 c=vec4(L,F,Z,Z),q=fract(abs(vec4(sin(2.4*i+vec2(Z,H)).xyxy*.1*(vec2(Z,.1)+t+1e2).xxyy)));q=min(q,L-q)*2.*r.xyxy;b=(p-q.xy)*mat2(cos(atan(q.w-q.y,q.z-q.x)+vec4(Z,-H,H,Z)))/N;b.y=abs(b.y);o+=c.xxyz*e(max(-b.x,dot(vec2(F,.886),vec2(-L,Z)+b)),1e3)+c.xyyx*e(length(b),10.)+c.zyxx*e(length(vec2(L,Z)-b),10.);}}
*/

void main(){
    // main0();
    // main1();
    main2();
}