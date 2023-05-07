precision highp float;
uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

void main(){
    vec3 rgb = vec3(gl_FragCoord.xy / resolution.xy, 0.0);
    gl_FragColor=vec4(rgb,1);
}