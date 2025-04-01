// Classe particella background
class BackgroundParticle {
  float x, y;   // Posizione attuale
  float baseX, baseY; // Posizione di origine
  int col;      // Colore della particella
  float angle;  // Angolo per oscillazione

  BackgroundParticle(float x, float y, int col) {
    this.x = x;
    this.y = y;
    this.baseX = x;
    this.baseY = y;
    this.col = col;
    this.angle = random(TWO_PI);
  }

  void update() {
    // Movimento oscillatorio basato su sinusoidi
    angle += 0.09; // Velocità di oscillazione
    x = baseX + sin(angle) * 15; // Oscillazione orizzontale
    y = baseY + cos(angle) * 15; // Oscillazione verticale
  }

  void display() {
    noStroke();
    fill(col, 150); // Usa il colore dell'immagine con trasparenza
    
    // Disegna una forma pennellata
    pushMatrix();
    translate(x, y);
    rotate(angle); // Ruota il pennello per creare varietà
    ellipse(0, 0, 10, 25); // Forma ovale allungata
    popMatrix();
  }
}
