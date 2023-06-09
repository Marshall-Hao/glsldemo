
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

vec3 backgroundColour() {
  // * uv 上每个坐标 距离 中心点位置
  // * 离中心越近，越小 越接近黑 0.0
  float distFromCenter = length(abs(vUvs - 0.5));
  
  float vignette = 1.0 - distFromCenter;
  
  // vignette = step(0.7,vignette);
  // * always smoothstep
  vignette = smoothstep(0.0,0.7,vignette);
  vignette = remap(vignette,0.0,1.0,0.3,1.0);


  return vec3(vignette);
}

vec3 drawGrid(vec3 colour, vec3 lineColour, float cellSpacing,float lineWidth) {
  vec2 center = vUvs - 0.5;
  // * 都map到res 每个cell 100px resolution
  vec2 cells = abs(fract(center * resolution / cellSpacing) - 0.5);
  // * cell中每个点 到cell 边缘的距离 反过来 相当于 float vignette = 1.0 - distFromCenter; 然后映射到实际的 spacing res
  float disToEdge = (0.5 -  max(cells.x,cells.y)) * cellSpacing;

  // * 离边缘差一丢丢 就划线， 相当于边缘线 因为很薄 0.05
  float lines = smoothstep(0.0,lineWidth,disToEdge);

  colour = mix(lineColour, colour, lines);

  return colour;


}

float sdfCircle(vec2 p,float r) {
  return length(p) - r;
}


// * 一点 到 两点一线的距离 公式
float sdfLine(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  // * line segemnt, the reflection pa on the line ab
  float h = clamp(dot(pa,ba) / dot(ba,ba),0.0,1.0);
  // *     P
  // *   / | (real normal distance)   PA - (BA * h)
  // * /___|_____
  // *A  h factor  (BA * h)     B 
  // * vector minus pa - ba * h(reflection factor) 
  return length(pa - ba * h);
}

// * 右上角 b
float sdfBox(vec2 p, vec2 b) {
  vec2 d = abs(p) - b;

  return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdHexagon( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}

mat2 rotate2D(float angle) {
  float s = sin(angle);
  float c = cos(angle);

  return mat2(
    c,-s,
    s,c
  );

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

float softMax(float a, float b, float k) {
  return log(exp(k * a) + exp(k * b)) / k;
}


float softMin(float a, float b, float k) {
  return -softMax(-a, -b, k);
}

float softMinValue(float a,float b,float k) {
  // float h = remap(a - b, -1.0/k, 1.0/k, 0.0 , 1.0);
  float h = exp(-b*k) / (exp(-a*k) + exp(-b*k));
  return h;
}

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);

void main() {
  // *  move to center then reconstruct the res based on the screen , easily to access the number
  vec2 pixelCoords = (vUvs - 0.5) * resolution;
  
  vec3 colour = backgroundColour();
  // * 每个格子相对 10 px, linewidth 相对1px
  colour = drawGrid(colour, vec3(0.5),10.0,1.0);
  // * 每个格子相对 100 px, linewidth 相对2px
  colour = drawGrid(colour, vec3(0.0),100.0,2.0);

  // float d = sdfCircle(pixelCoords,300.0);
  // //* d 小于 0 就在圆圈内， 所以step 值就是 0 ，红色
  // // * smoothstep 就可以在 距离 1.0， -1.0有个过渡，感觉更匀称， 然后 距离 《 -1。0 深一点
  // colour = mix(red * 0.5, colour, smoothstep(-1.0,1.0,d));
  // // * 距离 《 -5.0 浅一点 -1.0 ～ -5.0 深色，像是一个边缘 圆圈
  // colour = mix(red , colour, smoothstep(-5.0,0.0,d));

  // float d = sdfLine(pixelCoords,vec2(0,0), vec2(200.0,-75.0));
  // // * 距离在5内 才画
  // colour = mix(red,colour, step(5.0,d));

  // * 移动 x,y 距离
  // vec2 pos = pixelCoords - vec2(200.0,300.0);
  // pos *= rotate2D(time * 0.25);
  // float d = sdfBox(pos, vec2(200.0,50.0));
  // colour = mix(red,colour,step(0.0,d));

  // float d = sdHexagon(pixelCoords,300.0);
  // colour = mix(red,colour,step(0.0,d));

  float box = sdfBox(rotate2D(time * 0.5) * pixelCoords, vec2(200.0,100.0));
  float d1 = sdfCircle(pixelCoords - vec2(-300.0,-150.0),150.0);
  float d2 = sdfCircle(pixelCoords - vec2(300.0,-150.0),150.0);
  float d3 = sdfCircle(pixelCoords - vec2(0.0,200.0),150.0);
  float d = opUnion(opUnion(d1,d2),d3);

  // * 颜色上也自然 blend in soft color blending 
  vec3 sdfColour = mix(red,blue, smoothstep(0.0,1.0,softMinValue(box,d,0.01)));
  // * soft min together
  d = softMin(box,d,0.05);

  colour = mix(sdfColour * 0.5, colour, smoothstep(-1.0,1.0,d));
  colour = mix(sdfColour , colour, smoothstep(-5.0,0.0,d));

  gl_FragColor = vec4(colour, 1.0);
}