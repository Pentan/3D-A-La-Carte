precision mediump float;

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;


#define PI 3.14159265358979

vec3 rotX(vec3 p,float a){
    float s = sin(a);
    float c = cos(a); 
    return vec3(p.x, p.y * c - s * p.z, p.y * s + c * p.z);
}

vec3 rotY(vec3 p,float a){
    float s = sin(a);
    float c = cos(a); 
    return vec3( p.z * s + p.x * c, p.y, p.z * c - p.x * s);
}

vec3 rotZ(vec3 p,float a){
    float s = sin(a);
    float c = cos(a); 
    return vec3(p.x * c - s * p.y, p.x * s + c * p.y, p.z);
}

float hash(vec3 p) {
	return fract(sin(dot(p,vec3(127.1,311.7,572.1))) * 43758.5453);
}

float noise(vec3 p) {
	vec3 ip = floor(p);
	vec3 t = fract(p);
	t = t * t * t * (10.0 + t * (-15.0 + 6.0 * t));
	float n000 = hash(ip);
	float n100 = hash(ip + vec3(1.0,0.0,0.0));
	float n010 = hash(ip + vec3(0.0,1.0,0.0));
	float n001 = hash(ip + vec3(0.0,0.0,1.0));
	float n011 = hash(ip + vec3(1.0,1.0,0.0));
	float n110 = hash(ip + vec3(1.0,1.0,0.0));
	float n101 = hash(ip + vec3(1.0,0.0,1.0));
	float n111 = hash(ip + vec3(1.0,1.0,1.0));
	

	return mix(
		mix(
			mix(n000, n100, t.x),
			mix(n010, n110, t.x), t.y),
		mix(
			mix(n001, n101, t.x),
			mix(n011, n111, t.x), t.y), t.z);
}

float fbm(vec3 p) {
	float f = 0.0;
	f += noise(p) * 0.5;
	f += noise(p * 2.0) * 0.5;
	f += noise(p * 4.0) * 0.25;
	f += noise(p * 8.0) * 0.125;
	return f;
}

float wall(vec2 p, vec2 ip) {
	vec2 fp = p - ip;
	float h = hash(vec3(ip,0.0));
	float a = floor(h * 4.0) / 4.0 * PI * 2.0;
	vec2 n = vec2(sin(a), cos(a));
	return (dot(n, fp) > 0.0)? abs(dot(fp, vec2(n.y, -n.x))) : length(fp);
}

float map(vec2 p) {
	vec2 ip = floor(p);
	float d = 1e10;
	
	d = min(d, wall(p, ip));
	d = min(d, wall(p, ip + vec2(1.0, 0.0)));
	d = min(d, wall(p, ip + vec2(0.0, 1.0)));
	d = min(d, wall(p, ip + vec2(1.0, 1.0)));
	
	return d;
}

float plane(vec3 p, vec4 n) {
	return abs(dot(p, n.xyz) - n.w);
}

float sphere(vec3 p, float r) {
	return length(p) - r;
}

float maze(vec3 p, vec2 mo) {
	float d0 = max(0.0, plane(p, vec4(0.0, 1.0, 0.0, 10.0)) - 0.02);
	float d1 = max(0.0, map(p.xz + mo) - 0.25);
	
	float d;
	//d = max(d0-0.1, d1);
	d = sqrt(d0 * d0 + d1 * d1) - 0.01;
	
	return d;
}

float grnd(vec3 p) {
	return plane(p, vec4(0.0, 1.0, 0.0, -2.0));
}

float scn(vec3 p) {
	float d = 1e10;
	
	vec3 tp ;
	tp = rotX(rotY(abs(p), -PI * 0.25), -PI * 0.25);
	
	d = maze(rotY(tp, time * 0.3), vec2(time * 0.1));
	d = min(d, maze(rotY(tp, time * -0.01) * 6.0, vec2(time *-0.2)) * 0.16667);
	//d = min(d, maze(rotY(tp, time) * 10.0, vec2(time *-0.2)) * 0.1);
	
	return d;
	
	//return min(maze(p), grnd(p));
}

vec3 nrm(vec3 p) {
	const vec3 EPS = vec3(0.001, 0.0, 0.0);
	vec3 n;

	n.x = scn(p + EPS.xyz) - scn(p - EPS.xyz);
	n.y = scn(p + EPS.zxy) - scn(p - EPS.zxy);
	n.z = scn(p + EPS.yzx) - scn(p - EPS.yzx);
	
	return normalize(n);
}
/*
float ao(vec3 p, vec3 n, float k) {
	const float STEP = 0.15;
	float ao = 0.0;
	float d;
	for(int i = 1; i <= 5; i++) {
		float t = float(i);
		d = STEP * t;
		ao += (d - scn(p + n * d)) / (t * t);
	}
	return max(0.0, 1.0 - ao * k);
}
*/

vec3 shade(vec3 p, vec3 eye) {
	vec3 c;
	vec3 n = nrm(p);
	//return n * 0.5 + 0.5;
	
	vec3 ev = normalize(eye-p);
	
	float d = max(0.0, dot(n, ev));
	
	return vec3(0.7, 0.95, 1.0) * d + vec3(1.0) * pow(d, 16.0);
	
}

vec3 rm(vec2 scrnp) {
	vec3 p = vec3(0.0, 0.0, 12.0);
	vec3 ray = normalize(vec3(scrnp, -4.0));
	
	float sl = length(scrnp);
	vec3 col = vec3(1.0, 1.2, 1.8) * exp(-sl * sl * 0.5);
	
	//return col;
	
	float R = time * 0.2;
	p = rotY(p, R);
	ray = rotY(ray, R);
	
	vec3 eye = p;
	float d = 1e10;
	for(int i = 0; i < 128; i++) {
		d = scn(p);
		if(d < 0.01) {
			col = shade(p, eye);
			break;
		}
		p += d * ray;
	}
	
	col *= exp(-sl * sl * 0.15);
	
	return col;
}

void main( void ) {

	vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / resolution.y;
	
	vec3 col = vec3(p.xy, 0.0);
	//col /= (1.0 + floor(max(abs(p.x), abs(p.y))));
#if 1
	col = rm(p);
#else
	float d;
	//d = map(p * 4.0);
	d = fbm(vec3(p * 4.0, 0.0));
	col = vec3(-d, d, exp(-d*d*4000.0));
#endif

	gl_FragColor = vec4(col, 1.0 );

}

