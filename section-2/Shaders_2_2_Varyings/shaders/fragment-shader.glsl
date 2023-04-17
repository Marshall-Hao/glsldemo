
varying vec2 vUvs;

void main() {
  // gl_FragColor = vec4(vec3(1.0 - vUvs.x), 1.0);
  //  转换位置
  gl_FragColor = vec4(vUvs.y,0.0,vUvs.x, 1.0);
}