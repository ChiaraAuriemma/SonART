class Particle {
  float x, y;
  float tx, ty;
  color currentColor;
  color nextColor;
  float angle;
  float waveAmplitude, waveFrequency;
  float particleSize;

  Particle(float x, float y, color c) {
    this.x = x;
    this.y = y;
    this.tx = x;
    this.ty = y;
    currentColor = c;
    nextColor = c;
    angle = random(TWO_PI);
    waveAmplitude = random(3, 5);
    waveFrequency = random(0.05, 0.1);
    particleSize = random(10, 25);
  }

  void setNext(float nx, float ny, color nc) {
    tx = nx;
    ty = ny;
    nextColor = nc;
  }

  void update() {
  if (isTransitioning) {
    float eased = ease(transitionProgress);
    
    // interpolazione completa verso il target
    x = lerp(x, tx, eased);
    y = lerp(y, ty, eased);
    currentColor = lerpColor(currentColor, nextColor, eased);
    
    // leggerissima vibrazione per mantenere un minimo di caos
    x += sin(angle) * 0.5;
    y += cos(angle) * 0.5;
    angle += waveFrequency;
    
  } else {
    x += sin(angle) * waveAmplitude;
    y += cos(angle) * waveAmplitude;
    angle += waveFrequency;
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
    return t * t * (3 - 2 * t);  // smoother easing
  }
}
