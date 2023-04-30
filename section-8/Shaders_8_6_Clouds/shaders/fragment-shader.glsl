
varying vec2 vUvs;
uniform vec2 resolution;
uniform float time;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

float opUnion(float d1, float d2) {
  return min(d1, d2);
}

float opSubtraction(float d1, float d2) {
  return max(-d1, d2);
}

float opIntersection(float d1, float d2) {
  return max(d1, d2);
}

float sdfCircle(vec2 p, float r) {
    return length(p) - r;
}

mat2 rotate2D(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

vec3 DrawBackground() {
  return mix(vec3(0.42,0.58,0.75),
  vec3(0.36,0.46,0.82),
  smoothstep(0.0,1.0,pow(vUvs.x * vUvs.y, 0.5)));
}


float sdfCloud(vec2 pixelCoords) {
  float puff1 = sdfCircle(pixelCoords,100.0);
  float puff2 = sdfCircle(pixelCoords - vec2(120.0,-10.0),75.0);
  float puff3 = sdfCircle(pixelCoords + vec2(120.0,10.0),75.0);

  return opUnion(puff1, opUnion(puff2,puff3));
}

float hash(vec2 v) {
  // * fake random
  float t = dot(v, vec2(36.5323,73.945));
  return sin(t);
}


void main() {
  vec2 pixelCoords = vUvs  * resolution;

  vec3 colour = DrawBackground();

  const float NUM_CLOUDS = 8.0;
  // * making clouds
  for (float i = 0.0; i < NUM_CLOUDS; i+=1.0) {
    // * 不同的size， hash 增加混乱程度
    float size = mix(2.0,1.0,(i / NUM_CLOUDS) + 0.1 * hash(vec2(i)));
    float speed = size * 0.25;


    // * 越大的 offset就会小点， 感觉就会移动的慢， 因为是减去 , hash 增加混乱程度
    vec2 offset = vec2(i*200.0 + time * 100.0 * speed,200.0 * hash(vec2(i)));
    vec2 pos = pixelCoords - offset;

    // * mod function - to +
    pos = mod(pos,resolution);
    //* 移动到中间
    pos = pos - resolution * 0.5;

    // * scale 就是 乘
    float cloudShadow = sdfCloud(pos * size + vec2(25.0)) - 40.0;
    float cloud = sdfCloud(pos * size);
    // * 越远 越接近 1 要用edge0 -》 edge1的思想,mix 就越黑 vec3(0.0)
    colour = mix(colour,vec3(0.0), 0.5 * smoothstep(0.0,-100.0,cloudShadow));
    // * smoothstep for anti alias
    colour = mix(vec3(1.0),colour,smoothstep(0.0,1.0,cloud));
  }

  gl_FragColor = vec4(colour, 1.0);
}