// Classe Particle
class Particle {
  PVector position;
  PVector velocity;
  PVector target;
  float maxSpeed = 2;
  float maxForce = 0;
  float w, h; // Dimensioni delle pennellate
  float rotation; // Rotazione della pennellata

  Particle(float x, float y) {
    position = new PVector(x, y);
    velocity = PVector.random2D();
    target = randomTarget(currentImage);
    w = random(5, 15); // Larghezza casuale
    h = random(20, 40); // Altezza casuale
    rotation = random(TWO_PI); // Rotazione casuale
  }

  void update() {
    // Transizione fluida tra target attuali e nuovi
    if (random(1) < 0.01) {
      target = blendTargets(target, randomTarget(nextImage));
    }

    // Movimento verso il target
    PVector desired = PVector.sub(target, position);
    float d = desired.mag();
    desired.normalize();
    if (d < 5) {
      velocity.mult(0.9); // Rallenta vicino al target
    } else {
      desired.mult(maxSpeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxForce);
      velocity.add(steer);
    }
    position.add(velocity);
  }

  void display() {
    noStroke();
    int c = lerpColor(currentImage.get((int)position.x, (int)position.y), 
                      nextImage.get((int)position.x, (int)position.y), 
                      transitionProgress);
    fill(c, 150);

    // Applicazione di rotazione e forma della pennellata
    pushMatrix();
    translate(position.x, position.y);
    rotate(rotation);
    ellipse(0, 0, w, h); // Rappresenta la pennellata
    popMatrix();
  }

  PVector randomTarget(PImage img) {
    while (true) {
      float x = random(width);
      float y = random(height);
      color c = img.get((int)x, (int)y);
      if (brightness(c) < 200) {
        return new PVector(x, y);
      }
    }
  }

  PVector blendTargets(PVector t1, PVector t2) {
    return PVector.lerp(t1, t2, 0.5); // Interpolazione tra target attuale e nuovo
  }
}
