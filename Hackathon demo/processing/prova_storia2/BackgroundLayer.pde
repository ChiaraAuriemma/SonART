class BackgroundLayer {
  ArrayList<BackgroundParticle> bgParticles = new ArrayList<BackgroundParticle>();  // Particelle di sfondo
  int particleCount;

  BackgroundLayer(PImage img1, int particleCount) {
    this.particleCount = particleCount;

    // Creazione delle particelle per il primo layer (sfondo)
    for (int i = 0; i < particleCount; i++) {
      float x = random(width);
      float y = random(height);
      int c = img1.get((int)x, (int)y);  // Colore preso dalla prima immagine
      bgParticles.add(new BackgroundParticle(x, y, c));  // Aggiungi la particella al layer di sfondo
    }
  }

  // Funzione per aggiornare e disegnare le particelle
  void updateAndDisplay(PGraphics layer) {
    for (BackgroundParticle p : bgParticles) {
      p.update();  // Aggiorna la posizione delle particelle
      p.display();  // Disegna la particella nel layer di sfondo
    }
  }
}
