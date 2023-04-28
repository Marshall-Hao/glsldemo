
varying vec2 vUvs;

uniform vec2 resolution;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

void main() {
  vec3 colour = vec3(0.75);

  // * grid
  // * fract 只保留小数， 所以0.1的边界相当于 1,所以一行 10个小格子
  // * 每个小方块的中心点了, each cell 100px , 就是 1000 / 100.0
  // * 左加右减 中心
  vec2 center = vUvs - 0.5;
  vec2 cell = fract(center * resolution / 100.0);
  cell = abs(cell - 0.5);
  // * 越中间越白， 2.0 * 接近于0
  float distToCell =1.0 - 2.0 * max(cell.x, cell.y);
  // * 靠近边边，接近于 0.0，所以cellLine是相当于 0， 所以边边是黑色，其它地方都接近0.05，所以是1，接近于白色
  float cellLine = smoothstep(0.0,0.05, distToCell);


  // * axises
  float xAxis = smoothstep(0.0,0.002, abs(vUvs.y - 0.5));
  float yAxis = smoothstep(0.0,0.002, abs(vUvs.x - 0.5));
  

  // * Lines
  vec2 pos = center * resolution / 100.0;
  float value1 = pos.x;
  // * 因为center 减去了个 0.5, 所以abs都是正的
  // float value2 = abs(pos.x);
  // * floor 都会找地板值 所以是 下边缘
  // float value2 = floor(pos.x);
  // * ceil 都会找天花板板值 所以是 上边缘
  // float value2 = ceil(pos.x);

  // * round 都会找中间
  // float value2 = round(pos.x);

  // * mod 取余数 负数就是 y - x 也是负变正 wow 难 要抽象
  float value2 = mod(pos.x, 1.43);

  float functionLine1 = smoothstep(0.0,0.075,abs(pos.y - value1));
  float functionLine2 = smoothstep(0.0,0.075,abs(pos.y - value2));


  
  // * 混合颜色
  colour = mix(black,colour, cellLine);
  colour = mix(blue,colour,xAxis);
  colour= mix(blue, colour, yAxis);
  // * functionLine1 百分比 越近于0， 越近于 yellow, 因为4度角， y和 x越近， abs value越相当于0， 所以越相当于edge0, 出来的百分比就是0
  colour = mix(yellow,colour, functionLine1);
  //* 因为abs 正了， 那么 x -0.2 就为0.2， y 还是0.2 ,所以为 0 接近edge0 ,所以颜色接近red, 因为 (0,0)点移动到了 中心， 左下角是 （-0.5，-0.5） （abs case)
  colour = mix(red,colour, functionLine2);


  gl_FragColor = vec4(colour, 1.0);
}
