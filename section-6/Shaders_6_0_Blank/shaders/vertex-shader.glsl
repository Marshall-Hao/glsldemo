

varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vUvs;
void main() {	
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  vUvs = uv;
  // * 拿到每个uvz点的垂直 向量
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz; 
  // * 拿到每个uv点的 modelMatrix 转换后的位置
  vPosition = (modelMatrix * vec4(position,1.0)).xyz;
}