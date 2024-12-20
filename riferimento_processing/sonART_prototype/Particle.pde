// Classe Particle
class Particle {
  PVector position;
  PVector velocity;
  PVector target;
  float maxSpeed = 2;
  float maxForce = 0.5;
  float w, h; // Dimensioni delle pennellate
  float rotation; // Rotazione della pennellata

  Particle(float x, float y) {
    position = new PVector(x, y);
    velocity = PVector.random2D();
    target = randomTarget(currentImage, currentX, currentY, currentWidth, currentHeight);
    w = 10; // Larghezza casuale
    h = 25; // Altezza casuale
    rotation = random(TWO_PI); // Rotazione casuale
  }

  void update() {
    // Transizione fluida tra target attuali e nuovi
    if (random(1) < 0.08) {
      target = blendTargets(target, randomTarget(nextImage, nextX, nextY, nextWidth, nextHeight));
    }

    // Movimento verso il target
    PVector desired = PVector.sub(target, position);
    float d = desired.mag();
    desired.normalize();
    if (d < 5) {
      velocity.mult(0.1); // Rallenta vicino al target
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
    int c = lerpColor(
      getColorFromImage(currentImage, currentX, currentY, currentWidth, currentHeight),
      getColorFromImage(nextImage, nextX, nextY, nextWidth, nextHeight),
      transitionProgress
    );

    // Controlla la trasparenza del colore
    if (alpha(c) > 0) { // Mostra solo se non è completamente trasparente
      fill(c, 150);

      // Applicazione di rotazione e forma della pennellata
      pushMatrix();
      translate(position.x, position.y);
      rotate(rotation);
      ellipse(0, 0, w, h); // Rappresenta la pennellata
      popMatrix();
    }
  }

  PVector randomTarget(PImage img, float imgX, float imgY, float imgWidth, float imgHeight) {
    while (true) {
      float x = random(imgX, imgX + imgWidth);
      float y = random(imgY, imgY + imgHeight);
      color c = img.get((int)map(x, imgX, imgX + imgWidth, 0, img.width), 
                        (int)map(y, imgY, imgY + imgHeight, 0, img.height));
      if (brightness(c) < 200 && alpha(c) > 0) { // Evita pixel trasparenti
        return new PVector(x, y);
      }
    }
  }

  int getColorFromImage(PImage img, float imgX, float imgY, float imgWidth, float imgHeight) {
    float mappedX = map(position.x, imgX, imgX + imgWidth, 0, img.width);
    float mappedY = map(position.y, imgY, imgY + imgHeight, 0, img.height);
    return img.get((int)mappedX, (int)mappedY);
  }

  PVector blendTargets(PVector t1, PVector t2) {
    return PVector.lerp(t1, t2, 0.5); // Interpolazione tra target attuale e nuovo
  }
}
