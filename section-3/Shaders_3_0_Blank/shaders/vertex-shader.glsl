
varying vec2 vUvs;


void main() {
  vec4 localPosition = vec4( position.x, position.y,0.0, 1.0);

  gl_Position = projectionMatrix * modelViewMatrix * localPosition;
  // * uv from the three.js
  vUvs = uv;
}