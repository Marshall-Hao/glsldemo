uniform float uTime;
uniform vec3 uColor;

varying vec3 vPosition;
varying vec3 vNormal;

void main()
{ 
// Normal
vec3 normal = normalize(vNormal);
if (!gl_FrontFacing)
{ 
  normal *= -1.0; 
}
  // stripes
float stripes = mod((vPosition.y - uTime * 0.02) * 20.0 ,1.0);
stripes = pow(stripes, 3.0);

// Fresnel
vec3 viewDirectionW = normalize(vPosition - cameraPosition);
float fresnel = dot(viewDirectionW, normal) + 1.0;
fresnel = pow(fresnel, 2.0);


// Fallof
float fallof = smoothstep(0.8,0.0,fresnel);

// Holographic
float holographic = stripes * fresnel;
holographic += fresnel * 1.25;
holographic *= fallof;


  // Final color
  gl_FragColor = vec4(uColor.x,uColor.y + vPosition.y,uColor.z, holographic);
 
  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}