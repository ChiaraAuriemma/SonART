class Particle {
  float x, y;
  float tx, ty;
  color currentColor;
  color nextColor;

  float angle, waveAmplitude, waveFrequency, particleSize;

  Particle(float x, float y, color c) {
    this.x = x;
    this.y = y;
    this.tx = x;
    this.ty = y;
    currentColor = c;
    nextColor = c;
    angle = random(TWO_PI);
    waveAmplitude = random(5, 20);
    waveFrequency = random(0.03, 0.08);
    particleSize = random(10, 25);
  }

  void setNext(float nx, float ny, color nc) {
    tx = nx;
    ty = ny;
    nextColor = nc;
  }

void update(boolean transitioning, float progress, float dt) {
    if (transitioning) {
      float eased = ease(progress);
      float decay = 1.0 - eased;

      
      x = lerp(x, tx, progress*0.1);
      y = lerp(y, ty, progress*0.1);
      

      x += sin(angle) * waveAmplitude * decay * dt * 30;
      y += cos(angle) * waveAmplitude * decay * dt * 30;

      angle += waveFrequency * dt * 60;

      currentColor = lerpColor(currentColor, nextColor, eased);

    } else {
      currentColor = nextColor;
      x += sin(angle) * 0.3 * dt * 10;
      y += cos(angle) * 0.3 * dt * 10;
      angle += waveFrequency * dt * 30;
    }
 }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);
    noStroke();
    fill(currentColor, 150);
    rectMode(CENTER);
    rect(0, 0, particleSize * 1.5, particleSize * 0.8);
    popMatrix();
  }

  float ease(float t) {
    return t * t * (3 - 2 * t);
  }
}
