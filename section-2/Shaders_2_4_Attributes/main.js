import * as THREE from "https://cdn.skypack.dev/three@0.136";

class SimonDevGLSLCourse {
  constructor() {}

  async initialize() {
    this.threejs_ = new THREE.WebGLRenderer();
    document.body.appendChild(this.threejs_.domElement);

    window.addEventListener(
      "resize",
      () => {
        this.onWindowResize_();
      },
      false
    );

    this.scene_ = new THREE.Scene();

    this.camera_ = new THREE.OrthographicCamera(
      0,
      1,
      1,
      0,
      0.1,
      1000
    );
    this.camera_.position.set(0, 0, 1);

    await this.setupProject_();

    this.onWindowResize_();
    this.raf_();
  }

  async setupProject_() {
    const vsh = await fetch("./shaders/vertex-shader.glsl");
    const fsh = await fetch(
      "./shaders/fragment-shader.glsl"
    );

    const material = new THREE.ShaderMaterial({
      uniforms: {},
      vertexShader: await vsh.text(),
      fragmentShader: await fsh.text(),
    });

    const geometry = new THREE.PlaneGeometry(1, 1);

    const colours = [
      new THREE.Color(0xff0000),
      new THREE.Color(0x00ff00),
      new THREE.Color(0x0000ff),
      new THREE.Color(0x00ffff),
    ];
    // * Color class
    console.log(colours[0]);
    const colourFloats = colours
      // * covert the color class to an array, toArray is a color class method
      .map((c) => c.toArray())
      .flat();
    console.log(colourFloats);
    // * (12) [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1]
    console.log(
      new THREE.Float32BufferAttribute(colourFloats, 3)
    );
    geometry.setAttribute(
      // * give an attribute name to vertex shader
      "simondevColours",
      // * every 3 represent a color, floating point value, shader needs float
      // * 给四个顶点标注颜色
      new THREE.Float32BufferAttribute(colourFloats, 3)
    );

    const plane = new THREE.Mesh(geometry, material);
    plane.position.set(0.5, 0.5, 0);
    this.scene_.add(plane);
  }

  onWindowResize_() {
    this.threejs_.setSize(
      window.innerWidth,
      window.innerHeight
    );
  }

  raf_() {
    requestAnimationFrame((t) => {
      this.threejs_.render(this.scene_, this.camera_);
      this.raf_();
    });
  }
}

let APP_ = null;

window.addEventListener("DOMContentLoaded", async () => {
  APP_ = new SimonDevGLSLCourse();
  await APP_.initialize();
});
