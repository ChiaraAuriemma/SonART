class ImageLayer {
  ArrayList<ImageParticle> imageParticles = new ArrayList<ImageParticle>();  // Particelle per l'immagine
  float baseX;  // Posizione X di base
  float baseY;  // Posizione Y di base

  // Costruttore che accetta img2 e la posizione di base
  ImageLayer(PImage img2, float baseX, float baseY) {
    this.baseX = baseX;  // Imposta la posizione di base X
    this.baseY = baseY;  // Imposta la posizione di base Y

    // Creazione delle particelle per il secondo layer (formazione dell'immagine sopra)
    for (int y = 0; y < img2.height; y++) {
      for (int x = 0; x < img2.width; x++) {
        int c = img2.get(x, y);  // Colore preso dall'immagine piccola
        if (brightness(c) > 50) {  // Aggiungi solo particelle con colori non troppo scuri
          float posX = baseX + x;  // Posizione X basata sulla posizione base
          float posY = baseY + y;  // Posizione Y basata sulla posizione base
          imageParticles.add(new ImageParticle(posX, posY, c));  // Aggiungi la particella al layer sovrapposto
        }
      }
    }
  }

  // Funzione per aggiornare e disegnare le particelle
  void updateAndDisplay(PGraphics layer) {
    for (ImageParticle p : imageParticles) {
      p.update();  // Movimento delle particelle
      p.display(layer);  // Disegna la particella nel secondo layer (fisso, sopra lo sfondo)
    }
  }
}
