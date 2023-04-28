

varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vUvs;
void main() {	
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  vUvs = uv;
  vNormal = (modelViewMatrix * vec4(normal,0.0)).xyz; 
}