
varying vec2 vUvs;
// * set the gloabal in three.js , uniform can be used anywhere
uniform vec4 colour1;
uniform vec4 colour2;

void main() {
  // * mix is x + a * (y - x) linear interpolates between x * y using a as the percentage 增长了 百分之a的值
  gl_FragColor = mix(colour1, colour2, vUvs.x);
}