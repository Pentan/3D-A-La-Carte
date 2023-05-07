precision highp float;
uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;
void main0(){
    vec3 rgb = vec3(gl_FragCoord.xy / resolution.xy, 0.0);

    vec2 p = gl_FragCoord.xy;

    rgb = vec3(0.0);
    for(float i = 0.0; i < 24.0; i+=1.0)
    {
        vec4 v = vec4(0.1, 0.2, 0.3, 0.05);
        vec4 q = v * (time + i * 0.05);
        q = fract(abs(q));
        q = min(q, 1.0 - q) * 2.0 * resolution.xyxy;
        
        vec2 s = p - q.xy;
        vec2 u = q.zw - q.xy;
        float d;
        d = length(s - u * clamp(dot(s, u) / dot(u, u), 0.0, 1.0));
        rgb += exp(-d*d*0.5) * 0.5;
    }

    gl_FragColor=vec4(rgb,1);
}

void main1(){
    vec4 o = vec4(0.0);
    vec2 r = resolution;
    float t = time;

    vec2 s,u,p = gl_FragCoord.xy;
    for(float d,i=.0;i<24.;i+=1.)
    {
        vec4 v=vec4(.17,.21,.23,.05),q=fract(abs(v*(t+i*.05)));
        q=min(q,1.-q)*2.*r.xyxy;
        s=p-q.xy;
        u=q.zw-q.xy;
        d=length(s-u*clamp(dot(s,u)/dot(u,u),.0,1.));
        o+=exp(-d*d*.5)*.8;
    }

    gl_FragColor=vec4(o.rgb,1);
}

/*
void main(){vec2 s,u,p=gl_FragCoord.xy;for(float d,i=.0;i<80.;i+=1.){vec4 v=vec4(.17,.21,.23,.05),q=fract(abs(v*(t+i*.02)));q=min(q,1.-q)*2.*r.xyxy;s=p-q.xy;u=q.zw-q.xy;d=length(s-u*clamp(dot(s,u)/dot(u,u),.0,1.));o+=exp(-d*d)*.3;}}
*/

void main(){
    // main0();
    main1();
}