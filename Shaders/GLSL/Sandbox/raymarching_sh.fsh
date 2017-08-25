#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

vec2 scene(vec3 p) {
	vec3 ip = normalize(p);
	float theta = acos(ip.z);
	float phi = atan(ip.y, ip.x);
	
	float sh = 0.0;
	// l=0
	sh += 0.282094791774 * cos(time);
	
	// l=1
	sh += 0.345494149471 * sin(phi) * sin(theta) * cos(time * 0.315);
	sh += 0.488602511903 * cos(theta) * cos(time * 1.572);
	sh += -0.345494149471 * cos(phi) * sin(theta) * cos(time * 2.765);
	
	// l=2
	sh += 0.386274202023 * sin(2.0 * phi) * pow(sin(theta), 2.0) * cos(time * 0.765);
	sh += 0.772548404046 * sin(phi) * sin(theta) * cos(theta) * cos(time * 1.928);
	sh += 0.315391565253 * (3.0 * pow(cos(theta), 2.0) - 1.0) * cos(time * 2.571);
	sh += -0.772548404046 * cos(phi) * sin(theta) * cos(theta) * cos(time * 3.691);
	sh += 0.386274202023 * cos(2.0 * phi) * pow(sin(theta), 2.0) * cos(time * 4.102);
	
	// l=3
	sh += 0.417223823633 * sin(3.0 * phi) * pow(sin(theta), 3.0) * cos(time * 0.592);
	sh += 1.02198547643 * sin(2.0 * phi) * pow(sin(theta), 2.0) * cos(theta) * cos(time * 1.284);
	sh += 0.323180184114 * sin(phi) * sin(theta) * (5.0 * pow(cos(theta), 2.0) - 1.0) * cos(time * 2.221);
	sh += 0.37317633259 * (5.0 * pow(cos(theta), 3.0) - 3.0 * cos(theta)) * cos(time * 3.912);
	sh += -0.323180184114 * cos(phi) * sin(theta) * (5.0 * pow(cos(theta), 2.0) - 1.0) * cos(time * 4.782);
	sh += 1.02198547643 * cos(2.0 * phi) * pow(sin(theta), 2.0) * cos(theta) * cos(time * 5.125);
	sh += -0.417223823633 * cos(3.0 * phi) * pow(sin(theta), 3.0) * cos(time * 6.192);
	
	float r = dot(p, ip);
	
	//return abs(sh);
	//return 1.0 / (1.0 + pow(r, 2.0)) * abs(sh);
	return vec2(r - abs(sh), sh); // distance
}

vec3 normal(vec3 p) {
	//const float EPS = 0.01;
	const vec3 ESP = vec3(0.01, 0.0, 0.0);
	vec3 norm;
	norm.x = scene(p + ESP).x - scene(p - ESP).x;
	norm.y = scene(p + ESP.zxy).x - scene(p - ESP.zxy).x;
	norm.z = scene(p + ESP.yzx).x - scene(p - ESP.yzx).x;
	return normalize(norm);
}

void main(void) {
	vec2 screen = (gl_FragCoord.xy * 2.0 - resolution) / resolution.yy;
	
	vec3 rgb = vec3(0.0);
	
	vec2 track = (mouse * 2.0 - 1.0) * 3.1415926535;
	vec2 s = sin(track);
	vec2 c = cos(track);
	mat3 trans = mat3(
		 c.x, -s.y*s.x,  c.y*s.x,
		 0.0,      c.y,      s.y,
		-s.x, -s.y*c.x,  c.y*c.x
	);
	
	vec3 dir = trans * normalize(vec3(screen, -4.0));
	vec3 p = trans * (vec3(0.0, 0.0, 8.0)) + dir * 6.0;
	vec3 pp = p;
	
	const float STEP = 0.0625;
	for(int i = 0; i < 64; i++) {
		p += dir * STEP;
		float d = scene(p).x;
		if(d < 0.0) {
			vec3 np = p;
			for(int j = 0; j < 8; j++) {
				if(abs(d) < 0.0001) break;
				p = (pp + np) * 0.5;
				d = scene(p).x;
				if(d < 0.0) {
					np = p;
				} else {
					pp = p;
				}
			}
			//rgb = normal(p) * 0.5 + 0.5;
			vec3 nv = normal(p);
			float ao = clamp(abs(scene(p).y), 0.0, 1.0) * 0.8 + 0.2;
			//rgb = vec3(ao);
			vec3 litvec = trans * vec3(0.577);
			rgb = vec3(max(dot(nv, litvec), 0.0) * 0.8 + 0.2) * ao;
			break;
		}
		pp = p;
	}
	
	/*
	const float STEP = 0.125;
	float d = 0.0;
	for(int i = 0; i < 32; i++) {
		p += dir * STEP;
		d += scene(p);
	}
	rgb = vec3(d / 20.0);
	*/
	gl_FragColor = vec4(rgb, 1.0);
	//gl_FragColor = max(vec4(screen, 0.0, 1.0), vec4(0.0, -screen, 1.0));
}
