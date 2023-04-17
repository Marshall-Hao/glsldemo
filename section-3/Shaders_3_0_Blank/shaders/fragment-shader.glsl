varying vec2 vUvs;
// * for 2Dtexture 
uniform sampler2D diffuse;
uniform sampler2D overlay;
// * 是个vector4 不是图像
uniform vec4 tint;
void main(void) {
  //  * 2D texture return rgba
  // * flip out
  // vec4 diffuseSample = texture2D(diffuse,(1.0 - vUvs));
  vec4 diffuseSample = texture2D(diffuse,vUvs);
  vec4 overlaySample = texture2D(overlay,vUvs);
  // * only r channel, 只有r所以是红的 （1，0，0）是红的， multiplicative blending color1 * color2
  //* need to change the alpha chaneel, a 是 0的话，就显示 x 全部， a是1的话，就显示 y全部， a相当于是进程
  gl_FragColor = mix(diffuseSample,overlaySample,overlaySample.w) ;
}