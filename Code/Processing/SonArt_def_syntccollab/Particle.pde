// class particle 
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

  void update() {
    if (transitioning) {
      float eased = ease(transitionProgress);
    
      // Decrescita della waveAmplitude
      float decay = 1.0 - eased; // da 1 → 0
      //float decay = pow(1.0 - eased, 2);  // decay più lenta, effetto più graduale
      
      x = lerp(x, tx, eased * 0.1);
      y = lerp(y, ty, eased * 0.1);
    
      x += sin(angle) * (waveAmplitude * decay);
      y += cos(angle) * (waveAmplitude * decay);
    
      angle += waveFrequency;
    
      currentColor = lerpColor(currentColor, nextColor, eased * 0.05);
    } else {
      
      x += sin(angle) * 0.3;
      y += cos(angle) * 0.3;
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
    return t * t * (3 - 2 * t);
  }
}
