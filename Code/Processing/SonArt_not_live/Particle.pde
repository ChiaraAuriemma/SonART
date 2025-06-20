class Particle {
  float x, y;
  float tx, ty;
  color currentColor;
  color nextColor;
  float angle, r;

  float waveAmplitude;
  float waveFrequency;
  float particleSize;

  Particle(float x, float y, color c) {
    this.x = x;
    this.y = y;
    this.tx = x;
    this.ty = y;

    currentColor = c;
    nextColor = c;
    angle = random(TWO_PI);
    r = random(0.8, 1.2);
    waveAmplitude = random(5, 15);
    waveFrequency = random(0.03, 0.08);
    particleSize = random(10, 25);
  }

  void setNext(float nx, float ny, color nc) {
    tx = nx;
    ty = ny;
    nextColor = nc;
  }

  void update(boolean transitioning, float transitionProgress, int transitionDuration, float dt) {
    if (transitioning) {
      float eased = ease(transitionProgress);
      float decay = (transitionDuration < 1000) ? eased : 1.0 - eased;

      x = lerp(x, tx, eased);
      y = lerp(y, ty, eased);

      x += sin(angle) * (waveAmplitude * decay) * dt * 30;
      y += cos(angle) * (waveAmplitude * decay) * dt * 30;

      angle += waveFrequency * dt * 30;

      currentColor = lerpColor(currentColor, nextColor, eased);
    } else {
      float oscillationSpeed = 0.3f;
      x += sin(angle) * oscillationSpeed * dt * 10;
      y += cos(angle) * oscillationSpeed * dt * 10;

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
