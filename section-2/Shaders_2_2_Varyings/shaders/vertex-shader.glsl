// * get the  vUvs accessible for fragment shader
// * uv from the three.js uv cord uv
varying vec2 vUvs;

void main() {	
  vec4 localPosition = vec4(position, 1.0);
  // * projectionMatrix and modelViewMatrix provided by three.js project * modelview *position
  gl_Position = projectionMatrix * modelViewMatrix * localPosition;
  vUvs = uv;
}