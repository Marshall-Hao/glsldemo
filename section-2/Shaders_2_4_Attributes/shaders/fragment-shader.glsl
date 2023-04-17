
varying vec3 vColour;
// * varying 所以会自动 interpolation
void main() {
  gl_FragColor = vec4(vColour, 1.0);
}