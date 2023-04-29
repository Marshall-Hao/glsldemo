
varying vec3 vNormal;
varying vec3 vPosition;

uniform float time;


float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

mat3 rotateY(float radians) {
  float s = sin(radians);
  float c = cos(radians);

  return mat3(
    c,0.0,s,
    0.0,1.0,0.0,
    -s,0.0,c
  );
}

mat3 rotateX(float radians) {
  float s = sin(radians);
  float c = cos(radians);

  return mat3(
    1,0,0,
    0,c,-s,
    0,s,c
  );
}


mat3 rotateZ(float radians) {
  float s = sin(radians);
  float c = cos(radians);

  return mat3(
    c,-s,0,
    s,c,0,
    0,0,1
  );
}

void main() {	
  // * from the attribute position xyz
  vec3 localSpacePosition = position;
  // localSpacePosition.z += sin(time);
  // * multiply is the scale
  // localSpacePosition.xyz *= remap(sin(time),-1.0,1.0,0.5,1.5);
  localSpacePosition.y += sin(time);
  //* rotation relative the actual origin, understand , can teach
  localSpacePosition = rotateX(time) * localSpacePosition;


  // * 4 * 4 matrix
  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0);
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vPosition = (modelMatrix * vec4(localSpacePosition, 1.0)).xyz;
}