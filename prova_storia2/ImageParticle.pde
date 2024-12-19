
// Classe per le particelle che formano l'immagine sopra lo sfondo
class ImageParticle {
  float x, y;  // Posizione della particella
  int col;  // Colore della particella

  ImageParticle(float x, float y, int col) {
    this.x = x;
    this.y = y;
    this.col = col;
  }

  void update() {
    // Movimento delle particelle (puoi cambiare questa logica a seconda dell'effetto che vuoi)
    x += random(-1, 1);  // Movimento casuale orizzontale
    y += random(-1, 1);  // Movimento casuale verticale
  }

  void display(PGraphics pg) {
    pg.noStroke();
    pg.fill(col);  // Colore della particella
    pg.ellipse(x, y, 5, 8);  // Disegna la particella (forma piccola)
  }
}
