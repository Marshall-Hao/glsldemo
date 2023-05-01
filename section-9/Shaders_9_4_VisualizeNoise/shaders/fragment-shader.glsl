
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

// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// https://www.youtube.com/c/InigoQuilez
// https://iquilezles.org/
//
// https://www.shadertoy.com/view/Xsl3Dl
vec3 hash( vec3 p ) // replace this by something better
{
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
            dot(p,vec3(269.5,183.3,246.1)),
            dot(p,vec3(113.5,271.9,124.6)));

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

// * 3d noise
float noise( in vec3 p )
{
  vec3 i = floor( p );
  vec3 f = fract( p );
	
	vec3 u = f*f*(3.0-2.0*f);

  return mix( mix( mix( dot( hash( i + vec3(0.0,0.0,0.0) ), f - vec3(0.0,0.0,0.0) ), 
                        dot( hash( i + vec3(1.0,0.0,0.0) ), f - vec3(1.0,0.0,0.0) ), u.x),
                   mix( dot( hash( i + vec3(0.0,1.0,0.0) ), f - vec3(0.0,1.0,0.0) ), 
                        dot( hash( i + vec3(1.0,1.0,0.0) ), f - vec3(1.0,1.0,0.0) ), u.x), u.y),
              mix( mix( dot( hash( i + vec3(0.0,0.0,1.0) ), f - vec3(0.0,0.0,1.0) ), 
                        dot( hash( i + vec3(1.0,0.0,1.0) ), f - vec3(1.0,0.0,1.0) ), u.x),
                   mix( dot( hash( i + vec3(0.0,1.0,1.0) ), f - vec3(0.0,1.0,1.0) ), 
                        dot( hash( i + vec3(1.0,1.0,1.0) ), f - vec3(1.0,1.0,1.0) ), u.x), u.y), u.z );
}

// * ocataves ， persistence persistence（how fast the amplitude goes down with each objective,how much the frequency increase with each other 
float fbm(vec3 p, int octaves, float persistence, float lacunarity) {
  float amplitude = 0.5;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; ++i) {
    float noiseValue = noise(p * frequency);
    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistence;
    frequency *= lacunarity;
  }

  total /= normalization;

  return total;
}

float ridgedFBM(vec3 p, int octaves, float persistence, float lacunarity) {
  float amplitude = 0.5;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; ++i) {
    float noiseValue = noise(p * frequency);
    // * get absolute value
    noiseValue = abs(noiseValue);
    noiseValue = 1.0 - noiseValue;

    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistence;
    frequency *= lacunarity;
  }

  total /= normalization;
  total *= total;

  return total;
}

float turbulenceFBM(vec3 p, int octaves, float persistence, float lacunarity) {
  float amplitude = 0.5;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; ++i) {
    float noiseValue = noise(p * frequency);
    noiseValue = abs(noiseValue);
    // * dont 1 - ; invertred; organic looking
    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistence;
    frequency *= lacunarity;
  }

  total /= normalization;

  return total;
}

float cellular(vec3 coords) {
  // * 找到 那个点 处在的cell的边界
  vec2 gridBasePosition = floor(coords.xy);
  // * 那个点在那个cell的偏移量
  vec2 gridCoordOffset = fract(coords.xy);

  float closest = 1.0;
  // * 2层layer 可自定义
  // * 2 * 2 附近四个
  for (float y = -2.0; y <= 2.0; y += 1.0) {
    for (float x = -2.0; x <= 2.0; x += 1.0) {
      vec2 neighbourCellPosition = vec2(x, y);
      // * 两个cell组合一下
      vec2 cellWorldPosition = gridBasePosition + neighbourCellPosition;
      // * sample noise two 2 times
      vec2 cellOffset = vec2(
        noise(vec3(cellWorldPosition, coords.z) + vec3(243.432, 324.235, 0.0)),
        noise(vec3(cellWorldPosition, coords.z))
      );
      
      // * 要画图来看
      float distToNeighbour = length(
          neighbourCellPosition + cellOffset - gridCoordOffset);
      closest = min(closest, distToNeighbour);
    }
  }

  return closest;
}

float stepped(float noiseSample) {
  float steppedSample = floor(noiseSample * 10.0) / 10.0;
  // * get fraction
  float remainder = fract(noiseSample * 10.0);
  // * get rid of the fraction
  steppedSample = (steppedSample - remainder) * 0.5 + 0.5;
  //* 变成 0 or 1
  return steppedSample;
}

// * noise sample
float domainWarpingFBM(vec3 coords) {
  // * fbm combinenation
  // * noise offset
  vec3 offset = vec3(
    fbm(coords, 4, 0.5, 2.0),
    // * some offset
    fbm(coords + vec3(43.235, 23.112, 0.0), 4, 0.5, 2.0), 0.0);
  // float noiseSample = fbm(coords + offset, 1, 0.5, 2.0);

  // * noise offset
  vec3 offset2 = vec3(
    fbm(coords + 4.0 * offset + vec3(5.325, 1.421, 3.235), 4, 0.5, 2.0),
    fbm(coords + 4.0 * offset + vec3(4.32, 0.532, 6.324), 4, 0.5, 2.0), 0.0);
  float noiseSample = fbm(coords + 4.0 * offset2, 1, 0.5, 2.0);

  return noiseSample;
}

void main() {
  // * 让坐标的z随着时间动
  vec3 coords = vec3(vUvs * 10.0, time * 0.2);
  float noiseSample = 0.0;

  // * noise 是 -1 到 1, 所以remap
  // noiseSample = remap(noise(coords),-1.0,1.0,0.0,1.0);
  // * more noise details merging
  // noiseSample = remap(fbm(coords,16,0.5,2.0),-1.0,1.0,0.0,1.0);
  // * rigidFBM noise 都是大于0的，不用remap
  // noiseSample =  ridgedFBM(coords, 4, 0.5,2.0);

  noiseSample =  turbulenceFBM(coords, 4, 0.5,2.0);


  // * like organic cell
  // noiseSample =1.0 - cellular(coords);
  // noiseSample = stepped(noiseSample); // * like wood
  // * like liquid metal
  // noiseSample += remap(domainWarpingFBM(coords),-1.0,1.0,0.0,1.0);
  // * more noise details merging
  vec3 colour = vec3(noiseSample);

  // * four samples each direction, get the width of a pixel, 4大块, 一块就0.5 宽高 uv坐标里
  // * 这个可以得到屏幕res坐标系里 每一小块占多少pixel
  vec3 pixel = vec3(0.5 / resolution, 0.0);

  // * 每个点上下左右一个pixel的噪声 noise
  // * 左边的 xzz (x,0,0)
  float s1 = turbulenceFBM(coords + pixel.xzz,4 ,0.5,2.0);
  // * 右边的
  float s2 = turbulenceFBM(coords - pixel.xzz,4 ,0.5,2.0);
  // * 下边的
  float s3 = turbulenceFBM(coords + pixel.zyz,4 ,0.5,2.0);
 // * 上边的
  float s4 = turbulenceFBM(coords - pixel.zyz,4 ,0.5,2.0);
  // * 每个点 的 normal noise
  vec3 normal = normalize(vec3(s1 - s2, s3 - s4, 0.001));
  // * Hemi
  vec3 skyColour = vec3(0.0, 0.3, 0.6);
  vec3 groundColour = vec3(0.6, 0.3, 0.1);

  //* 光打在3d噪声上
  vec3 hemi = mix(groundColour, skyColour, remap(normal.y, -1.0, 1.0, 0.0, 1.0));

  // * Diffuse lighting 光打在 3d噪声上
  vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
  vec3 lightColour = vec3(1.0, 1.0, 0.9);
  float dp = max(0.0, dot(lightDir, normal));

  vec3 diffuse = dp * lightColour;
  vec3 specular = vec3(0.0);

  // * Specular 光打在 3d噪声上
  vec3 r = normalize(reflect(-lightDir, normal));
  float phongValue = max(0.0, dot(vec3(0.0, 0.0, 1.0), r));
  phongValue = pow(phongValue, 32.0);

  specular += phongValue;

  vec3 baseColour = mix(
    vec3(1.0, 0.25, 0.25),
    vec3(1.0, 0.75, 0.0), smoothstep(0.0, 1.0, noiseSample));

  vec3 lighting = hemi * 0.125 + diffuse * 0.5;

  colour = baseColour * lighting + specular;
  colour = pow(colour,vec3(1.0/2.2));
  // * normal noise feel
  gl_FragColor = vec4(colour, 1.0);
}

  // // noiseSample = remap(noise(coords), -1.0, 1.0, 0.0, 1.0);
  // // noiseSample = remap(fbm(coords, 16, 0.5, 2.0), -1.0, 1.0, 0.0, 1.0);
  // // noiseSample = ridgedFBM(coords, 4, 0.5, 2.0);
  // noiseSample = turbulenceFBM(coords, 4, 0.5, 2.0);
  // // noiseSample = 1.0 - cellular(coords);
  // // noiseSample = stepped(noiseSample);
  // // noiseSample = remap(
  // //     domainWarpingFBM(coords), -1.0, 1.0, 0.0, 1.0);

  // vec3 colour = vec3(noiseSample);

  // vec3 pixel = vec3(0.5 / resolution, 0.0);

  // float s1 = turbulenceFBM(coords + pixel.xzz, 4, 0.5, 2.0);
  // float s2 = turbulenceFBM(coords - pixel.xzz, 4, 0.5, 2.0);
  // float s3 = turbulenceFBM(coords + pixel.zyz, 4, 0.5, 2.0);
  // float s4 = turbulenceFBM(coords - pixel.zyz, 4, 0.5, 2.0);
  // vec3 normal = normalize(vec3(s1 - s2, s3 - s4, 0.001));

  // // Hemi
  // vec3 skyColour = vec3(0.0, 0.3, 0.6);
  // vec3 groundColour = vec3(0.6, 0.3, 0.1);

  // vec3 hemi = mix(groundColour, skyColour, remap(normal.y, -1.0, 1.0, 0.0, 1.0));

  // // Diffuse lighting
  // vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
  // vec3 lightColour = vec3(1.0, 1.0, 0.9);
  // float dp = max(0.0, dot(lightDir, normal));

  // vec3 diffuse = dp * lightColour;
  // vec3 specular = vec3(0.0);

  // // Specular
  // vec3 r = normalize(reflect(-lightDir, normal));
  // float phongValue = max(0.0, dot(vec3(0.0, 0.0, 1.0), r));
  // phongValue = pow(phongValue, 32.0);

  // specular += phongValue;

  // vec3 baseColour = mix(
  //   vec3(1.0, 0.25, 0.25),
  //   vec3(1.0, 0.75, 0.0), smoothstep(0.0, 1.0, noiseSample));

  // vec3 lighting = hemi * 0.125 + diffuse * 0.5;

  // colour = baseColour * lighting + specular;
  // colour = pow(colour, vec3(1.0 / 2.2));
