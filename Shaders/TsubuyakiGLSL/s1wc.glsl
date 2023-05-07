precision highp float;
uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

#define PI 3.14159265358979



void main()
{
    vec3 rgb = vec3(1.0, 0.5, 0.25);
    gl_FragColor = vec4(rgb, 1.0);
}