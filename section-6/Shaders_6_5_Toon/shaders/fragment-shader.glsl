
uniform samplerCube specMap;

varying vec3 vNormal;
varying vec3 vPosition;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 linearTosRGB(vec3 value ) {
  vec3 lt = vec3(lessThanEqual(value.rgb, vec3(0.0031308)));
  
  vec3 v1 = value * 12.92;
  vec3 v2 = pow(value.xyz, vec3(0.41666)) * 1.055 - vec3(0.055);

	return mix(v2, v1, lt);
}

void main() {
  vec3 modelColour = vec3(0.5);
  vec3 lighting = vec3(0.0);

  vec3 normal = normalize(vNormal);
  vec3 viewDir = normalize(cameraPosition - vPosition);

  // Ambient
  vec3 ambient = vec3(1.0);

  // Hemi
  vec3 skyColour = vec3(0.0, 0.3, 0.6);
  vec3 groundColour = vec3(0.6, 0.3, 0.1);

  vec3 hemi = mix(groundColour, skyColour, remap(normal.y, -1.0, 1.0, 0.0, 1.0));

  // Diffuse lighting
  vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
  vec3 lightColour = vec3(1.0, 1.0, 0.9);
  // * 每个 点 不同的 光照夹角强度
  float dp = max(0.0, dot(lightDir, normal));

   // * Toon
  dp *= smoothstep(0.5,0.505, dp);

  vec3 specular = vec3(0.0);
  vec3 diffuse = dp * lightColour;
 
  // * specular
  vec3 r = normalize(reflect(-lightDir, normal));
  float phoneValue = max(0.0,dot(viewDir,r));
  phoneValue = pow(phoneValue,128.0);

  // * fresnel
  float fresnel = 1.0 - max(0.0,dot(viewDir,normal));
  fresnel = pow(fresnel,2.0);
  fresnel *= step(0.8,fresnel);

  specular += phoneValue;
  specular = smoothstep(0.5,0.51,specular);

  lighting = hemi * (fresnel + 0.2) + diffuse * 0.8;

  vec3 colour = modelColour * lighting + specular;

  gl_FragColor = vec4(pow(colour, vec3(1.0 / 2.2)), 1.0);
}