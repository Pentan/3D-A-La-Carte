precision mediump float;

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define PI	3.141592653589793
//#define PI2	6.283185307179586

vec2 rot(vec2 p, float a) {
	vec2 s = sin(a + vec2(0.0, PI * 0.5));
	return vec2(p.x *  s.y + p.y * s.x,
		    p.x * -s.x + p.y * s.y);
}

float arc(vec2 p, float r, float sa, float ea) {
	vec2 lp = rot(p, (ea + sa) * 0.5);
	float th = abs(atan(lp.y, lp.x));
	th = max(0.0, th - (ea - sa) * 0.5);
	vec2 pp = sin(th + vec2(0.0, PI * 0.5)) * length(p);
	
	return length(pp - vec2(0.0, r));
}

float ear(vec2 p) {
	vec2 lp = vec2(abs(p.x), p.y) - vec2(0.5, 0.7);
	float d = length(lp) - 0.4;
	float a = 0.5;
	vec2 n = vec2(-sin(a), cos(a));
	d = max(d, dot(n, lp) - 0.05);
	return d;
}

float no(vec2 p) {
	float w = 0.3;
	// の
	float d = arc(p + vec2(0.34, 0.0), 0.34, PI * 1.0, PI * 2.0) - w;
	d = min(d, arc(p + vec2(0.0), 0.68, PI * -0.18, PI * 1.0) - w);
	// ^^
	//d = ear(p);
	d = min(d, ear(p));
	return d;
}

void main( void ) {

	vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / resolution.y;
	p = (vec2(-0.05, 0.0) * time + rot(p, -0.5)) * 4.0;
	
	float ky = 1.6;
	p.x += floor(p.y / ky) * 4.313658;
	p = mod(p, vec2(10.0, ky));
	p.x = (p.x < 4.0)? fract(p.x) : (4.0 - p.x);
	p = p * 2.0 - 1.0;

	float d = no(p);
	
	vec3 color;
	//color = vec3(-d, d, exp(-d * d * 4000.0));
	//color /= 1.0 + floor(max(abs(p.x), abs(p.y)));
	
	color = mix(vec3(1.0, 0.96, 0.9), vec3(1.0, 0.7, 0.47), smoothstep(-0.02, 0.02, d));
	
	gl_FragColor = vec4(color, 1.0 );

}