

// tanjiro
precision highp float;uniform vec2 resolution;void main(){vec2 p=gl_FragCoord.xy/64.,q=fract(p);gl_FragColor=vec4(.1,.7,.5,1.)*step(.5,abs(q.x-step(.5,q.y)));}

// zenitsu
// precision highp float;uniform vec2 resolution;void main(){vec2 c=gl_FragCoord.xy,p=c/vec2(64.,55.4);p.x-=p.y*.5;gl_FragColor=(1.-step(.5,dot(vec2(1.),fract(p))))+mix(vec4(1.,.4,.0,1.),vec4(1.,.7,.0,1.),c.y/resolution.y);}

// nezuko
// precision highp float;uniform vec2 resolution;void main(){vec2 p=(gl_FragCoord.xy/64.*vec2(.58,1.)).yx;p=abs(fract(p)*2.-1.);p=(p.x>p.y)?p:1.-p;gl_FragColor=vec4(1.,.7,.7,1.)*step(.02,min(min(p.y,abs(min(dot(vec2(-.33,1.),p)*.95,1.-p.x))),dot(vec2(1.,-1.),p)*.71));}

#if 0
vec3 tanjiroh() {
    vec3 ret = vec3(0.0);
    vec2 p = fract(gl_FragCoord.xy / 64.0);
    ret.xy = p;

    float d = abs(p.x - step(0.5, p.y));
    // ret.xyz = vec3(step(0.5, d));
    ret.xyz = vec3(0.1, 0.7, 0.5) * step(0.5, d);

    return ret;
}

vec3 zenitsu() {
    vec3 ret = vec3(0.0);
    vec2 p = gl_FragCoord.xy / 64.0 / vec2(1.0, 0.87);
    p.x -= p.y * 0.5;
    p = fract(p);
    ret.xy = p;

    float d = dot(vec2(1.0), p);
    ret.xyz = vec3(-d, 0.0, d);

    ret.xyz = vec3(step(0.5, d));
    ret.rgb = (1.0 - step(0.5, d)) + mix(vec3(1.0, 0.4, 0.0), vec3(1.0, 0.7, 0.0), gl_FragCoord.y / resolution.y);

    return ret;
}

vec3 nezuko() {
    vec3 ret = vec3(0.0);
    vec2 p;
    p = gl_FragCoord.xy / 64.0 * vec2(0.578, 1.0);
    p = p.yx;
    p = abs(fract(p) * 2.0 - 1.0);
    p = (p.x > p.y) ? p : 1.0-p;
    ret.xy = p;

    float d;
    d = dot(vec2(-0.33,1.0), p) * 0.95;
    d = min(d, 1.0 - p.x);
    d = abs(d);
    d = min(d, p.y);
    d = min(d, dot(vec2(1.0, -1.0), p) * 0.71);
    // d = min(d, (p.x - p.y) * 0.707);
    ret.xyz = vec3(-d, 0.0, d) * 2.0;
    ret.xyz = vec3(step(0.02, d));
    ret.rgb = vec3(1.0, 0.7, 0.7) * step(0.02, d);

    return ret;
}

vec3 nezuko2() {
    vec3 ret = vec3(0.0);
    vec2 p;
    p = gl_FragCoord.xy / resolution.x * 4.0 * vec2(1.0, 1.15);
    p.x -= p.y * 0.5;
    p = fract(p);
    p = (p.x < 1.0 - p.y) ? p : 1.0 - p;
    p.x += p.y * 0.5;
    p.x = p.x - 0.5;
    p.x *= 2.0;
    p = abs(p);
    p.x = 1.0 - p.x;

    // p.x += p.y * 0.5;
    ret.xy = p;
    // ret.xyz = vec3(-p.x, 0.0, p.x);
    // ret.xyz = vec3(-p.y, 0.0, p.y);

    float d = 1.0 - p.x;
    d = min(d, dot(vec2(-0.33, 1.0), p)*0.95);
    d = abs(d);
    d = min(d, dot(vec2(1.0, -1.0), p)*0.71);
    d = min(d, p.y);
    ret.xyz = vec3(-d, 0.0, d) * 2.0;
    ret.xyz = vec3(step(0.02, d));

    return ret;
}

/*
#define e(d,x)exp(-d*d*x)
void main(){vec2 s,b,p=gl_FragCoord.xy;for(float d,F=.5,N=64.,H=1.57,L=1.,Z=.0,i=Z;i<N;i+=L){vec4 c=vec4(L,F,Z,Z),q=fract(abs(vec4(sin(2.4*i+vec2(Z,H)).xyxy*.1*(vec2(Z,.1)+t+1e2).xxyy)));q=min(q,L-q)*2.*r.xyxy;s=q.zw-q.xy;b=(p-q.xy)*mat2(cos(atan(s.y,s.x)+vec4(Z,-H,H,Z)))/N;b.y=abs(b.y);o+=c.xxyz*e(max(-b.x,dot(vec2(F,.886),vec2(-L,Z)+b)),1e3)+c.xyyx*e(length(b),10.)+c.zyxx*e(length(vec2(L,Z)-b),10.);}}
*/

void main(){
    vec3 rgb;
    // rgb = tanjiroh();
    // rgb = zenitsu();
    // rgb = nezuko();
    // rgb = nezuko2();
    rgb = m();
    
    gl_FragColor=vec4(rgb,1);
}
#endif
