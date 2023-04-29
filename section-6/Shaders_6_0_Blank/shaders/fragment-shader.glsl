varying vec3 vNormal;
varying vec3 vPosition;
// * 这个类型 因为是cube
uniform samplerCube specMap;

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
  vec3 baseColour = vec3(0.25,0,0);
  vec3 lighting = vec3(0.0);
  vec3 normal = normalize(vNormal);  
  
  // * 拿到 view的位置， cameraPosition from 3js internally , 归一
  vec3 viewDir = normalize(cameraPosition - vPosition);


  // * ambient
  vec3 ambient = vec3(0.5);

  // * hemi light
  vec3 skyColour = vec3(0.0,0.3,0.6);
  vec3 groundColour = vec3(0.6,0.3,0.0);

  // * normalize 只是abs 为 1,有可能出现 -1, 所以全部转为 0 ～ 1 范围
  float hemiMix = remap(normal.y, -1.0,1.0,0.0,1.0);
  // * 自然光
  vec3 hemi = mix(groundColour, skyColour, hemiMix);

  // * diffuse light
  vec3 lightDir = normalize(vec3(1.0,1.0,1.0));
  vec3 lightColour = vec3(1.0,1.0,0.9);
  // * 看光的位置 和 uv每个点的夹角 根据夹角大小 来映射灯光
  float dp = max(0.0,dot(lightDir,normal));

  vec3 diffuse = lightColour * dp;


  // * Phone specular
  // * 拿到光线在每个uv 垂直点的 投影 归u一
  vec3 r = normalize(reflect(-lightDir,normal ));
  // *中间的夹角光强度 abstract
  float phoneValue = max(0.0,dot(viewDir,r));
  phoneValue = pow(phoneValue,32.0);

  vec3 specular = vec3(phoneValue);
  
  
  // * IBL specular env mapping light
  // * 人视线 在 点normal 向量的投影 , 也就是direction
  vec3 iblCoord = normalize(reflect(-viewDir,normal));
  // * sample from it useing a direction vector
  vec3 iblSample = textureCube(specMap,iblCoord).xyz;

  specular += iblSample * 0.5;

  // * Fresnel (nice reflection)
  float fresnel =1.0 - max(0.0, dot(viewDir,normal));
  fresnel = pow(fresnel,2.0);
  // vec3 colour = vec3(fresnel);
  specular *= fresnel;


  // * intensity
  lighting = ambient * 0.0 + hemi * 0.0 + diffuse * 1.0;
  // * 单纯x1*x2 y1*y2 + specular hightlight
  vec3 colour  = baseColour * lighting + specular;

  // * 更真实
  // colour = linearTosRGB(colour);
  // * pow gamma 2.2
  colour = pow(colour,vec3(1.0/2.2));
  // colour = normal;
  gl_FragColor = vec4(colour, 1.0);
}