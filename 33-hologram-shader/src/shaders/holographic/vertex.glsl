uniform float uTime;
uniform vec3 uColor;
varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vColor;

#include "../includes/random2D.glsl"

void main()
{
  // Position
  vec4 modelPositon = modelMatrix * vec4(position, 1.0);

  // Glitch
  float glitchTime = uTime - modelPositon.y ;
  float glitchStrenghth = sin(glitchTime) + sin(glitchTime * 3.45) + sin(glitchTime * 8.76);
  glitchStrenghth = smoothstep(0.3,1.0,glitchStrenghth);
  glitchStrenghth *= 0.25;
  modelPositon.x += (random2D(modelPositon.xz + uTime) - 0.5) * glitchStrenghth;
  modelPositon.z += (random2D(modelPositon.zx + uTime) - 0.5) * glitchStrenghth;

  // Final Position
  gl_Position = projectionMatrix * viewMatrix * modelPositon;

  // Model Normal
  vec4 modelNormal = modelMatrix * vec4(normal, 0.0);

  // Varying
  vPosition = modelPositon.xyz;
  vNormal = modelNormal.xyz;
  vColor = uColor;
}