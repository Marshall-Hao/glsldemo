varying vec2 vUvs;

uniform sampler2D diffuse1;
uniform float time;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);
void main() {
  vec3 colour = vec3(0.0);
  vec4 diffuseSample = texture2D(diffuse1, vUvs);

  // * 因为sin 会有-1导致 blk时间过长
  float t = sin(time);

  // * 这个通过百分比 然后 将范围缩到 0 ～ 1 pingjun smooth pingpong
  t =  remap(t, -1.0, 1.0, 0.5,1.0);

  // float t1 = sin(vUvs.x * 1000.0);
  // * 三角函数 ，要shift就是调动 sin(kx-b) 的b值 b一直在变，那就一直shift
  float t2 = sin(vUvs.y * 400.0 - time * 2.0);
  // t1 = remap(t1,-1.0, 1.0, 0.5,1.0) * t;
  t2 = remap(t2,-1.0, 1.0, 0.5,1.0) ;
  // * time 一开始是0 慢慢变为1
  // colour = vec3(t1 * t2);
  colour =  vec3(t2);
  gl_FragColor = vec4(colour, 1.0) * diffuseSample;
}
