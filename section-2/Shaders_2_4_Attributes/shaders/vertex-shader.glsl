// * get the attribute, only for vertex
attribute vec3 simondevColours;
// * so need a varying to pass
varying vec3 vColour;

void main() {	
  vec4 localPosition = vec4(position, 1.0);

  gl_Position = projectionMatrix * modelViewMatrix * localPosition;
  vColour = simondevColours;
}