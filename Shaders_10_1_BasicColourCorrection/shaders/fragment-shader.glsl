
varying vec2 vUvs;
uniform vec2 resolution;
uniform float time;
uniform sampler2D diffuse1;
uniform sampler2D diffuse2;
uniform sampler2D vignette;


float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 saturate(vec3 x) {
  return clamp(x, vec3(0.0), vec3(1.0));
}

float saturate(float x) {
  return clamp(x, 0.0, 1.0);
}

float ColourDistance(vec3 c1, vec3 c2) {
  float rm = (c1.x + c2.x) * 0.5 * 256.0;
  vec3 d = (c1 - c2) * 256.0;

  float r = (2.0 + rm / 256.0) * d.x * d.x;
  float g = 4.0 * d.y * d.y;
  float b = (2.0 + (255.0 - rm) / 256.0) * d.z * d.z;
  return sqrt(r + g + b) / 256.0;
}

void main() {
  // * 图片分边 fract -> 0 ~ 1
  vec2 coords = fract(vUvs * vec2(2.0, 1.0));
  // * change image position,因为距离短了，压缩了，这样不让他压缩
  coords.x = remap(coords.x, 0.0,1.0,0.25,0.75);
  vec3 colour = texture2D(diffuse2,coords).xyz;

  if (vUvs.x > 0.5) {
    // * tinting
    vec3 tintColour = vec3(1.0,0.5,0.5);
    // colour  *= tintColour;

    // * brightness
    float brightnessAmount = 0.1;
    // colour += brightnessAmount;

    // * saturation 曝光度
    // * 得到灰度值
    float luminance = dot(colour, vec3(1.0/3.0));
    float saturationAmount = 0.5;
    // colour = mix(vec3(luminance),colour, saturationAmount);

    // * contrast 对比度
    float contrastAmount = 2.0;
    float midpoint = 0.5;
    // * remap the color from range 0 ~ 1 to -0.5 ~ 0.5, contrast is a multiplier and map back to 0 ~ 1
    // colour = (colour - midpoint) * contrastAmount + midpoint;

    // * contrastoperator 
    // * sign func, -1 < 0 1 > 0 
    vec3 sg = sign(colour - midpoint);
    // * all color channel
    // colour = sg * 
    //     pow(
    //       abs(colour - midpoint) * 2.0,
    //       vec3(1.0 / contrastAmount))
    //        * 0.5 + midpoint;

    // The matrix single color channel
    colour = pow(colour, vec3(1.5,0.8,1.5));
  }

  gl_FragColor = vec4(colour, 1.0);
}




