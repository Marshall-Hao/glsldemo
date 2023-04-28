
varying vec2 vUvs;

uniform vec2 resolution;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

void main() {
  vec3 colour = vec3(0.0);

  float value1 = vUvs.x;
  // * ease -in ease-out
  float value2 = smoothstep(0.0,1.0, value1);

  // * step function, u v 方向上0 - 1 延伸， 超过0.5 的地方直接变 1, 所以是白色
  // colour = vec3(step(0.3,vUvs.x));

  // * mix or lerp, u v 方向上0 - 1 延伸， a为0， 所以全红，没走动， 最后a 1，全蓝， 走完了， 中间是个linear gradient
  // colour = mix(red,blue, vUvs.x);

  // * smoothstep t= clamp((x-edge0) / (edge1 - edge0), 0.0, 1.0) ,x是希望达到的值, 然后获取一个 0  ～ 1中间的值 百分比 ，所以也像linear gradient
  // * 可以与 mix结合
  // colour = vec3(smoothstep(0.0,1.0,vUvs.x));
  // colour = mix(red,blue,smoothstep(0.0,1.0,vUvs.x));

  // * top half
  // * a line in the middle
  // * abs 会造成中间是黑的gradient，smoothstep可以 大于0.005，就是1 白色， 小于就是 接近于 0 黑色 中间都是接近的 所以形成一条黑线
  float line = smoothstep(0.0,0.005,abs(vUvs.y - 0.6));
  float line2 = smoothstep(0.0,0.005, abs(vUvs.y -  0.3));

  // *                                                          x 0 ～ 1，越接近1，越是 0.5往上， abs的值 y 与mix的值就越接近，就愈靠近edge0，于是就会是 edge0的值
  float linearLine = smoothstep(0.0,0.0075,abs(vUvs.y - mix(0.6,1.0,vUvs.x)));
  
  //*
  float smoothLine = smoothstep(0.0,0.0075,abs(vUvs.y - mix(0.0,0.3,value2)));

  // * 分两块颜色矩阵了
  if (vUvs.y > 0.6) {
    colour=mix(red,blue,vUvs.x);
  } else if (vUvs.y < 0.3) {
    colour = mix(red,blue,smoothstep(0.0,1.0,vUvs.x));
  } else {
    colour = mix(blue,red, vUvs.x);
  }

  //* 中间地方接近0，所以都是 x的值 也就是白色， 其它地方都是1,所以就是color本身的颜色
  colour = mix(white,colour,line);
  colour = mix(white, colour, line2);

  // * a越靠近edge0的值， 那么在mix里越靠近x的值,也就形成了白线
  colour = mix(white, colour, linearLine);

  colour = mix(white,colour,smoothLine);

  gl_FragColor = vec4(colour, 1.0);
}
