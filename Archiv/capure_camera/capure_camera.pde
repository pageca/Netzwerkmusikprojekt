import processing.video.*;
Particle[] particles;

//PImage frog;
Capture test;

void setup() {
  size(640, 360);

  test = new Capture(this, width, height);
  test.start();
  particles = new Particle [200];
  for (int i = 0; i < particles.length; i++) {
    particles[i] = new Particle();
  }
  background(0);
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {

  for (int i = 0; i < particles.length; i++) {
    particles[i].display();
    particles[i].move();
  }
}
