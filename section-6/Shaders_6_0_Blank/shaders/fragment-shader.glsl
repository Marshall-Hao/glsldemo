varying vec3 vNormal;


float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

void main() {
  vec3 baseColour = vec3(0.5);
  vec3 lighting = vec3(0.0);
  vec3 normal = normalize(vNormal);  
  
  // * ambient
  vec3 ambient = vec3(0.5);

  // * hemi light
  vec3 skyColour = vec3(0.0,0.3,0.6);
  vec3 groundColour = vec3(0.6,0.3,0.0);

  // * normalize 只是abs 为 1,有可能出现 -1, 所以全部转为 0 ～ 1 范围
  float hemiMix = remap(normal.y, -1.0,1.0,0.0,1.0);
  // * 自然光
  vec3 hemi = mix(groundColour, skyColour, hemiMix);

  lighting = ambient * 0.0 + hemi;
  vec3 colour  = baseColour * lighting;

  // colour = normal;
  gl_FragColor = vec4(colour, 1.0);
}