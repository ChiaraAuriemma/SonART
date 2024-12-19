PImage currentImage, nextImage;
ArrayList<Particle> particles;
float transitionProgress = 0; // Avanza gradualmente da 0 a 1 per la transizione

void setup() {
  size(800, 800);
  currentImage = loadImage("background.jpg");
  nextImage = loadImage("image4.jpg");
  currentImage.resize(width, height);
  nextImage.resize(width, height);

  particles = new ArrayList<Particle>();
  for (int i = 0; i < 8000; i++) {
    particles.add(new Particle(random(width), random(height)));
  }
}

void draw() {
  background(255);

  // Aggiorna particelle
  for (Particle p : particles) {
    p.update();
    p.display();
  }

  // Gestisci la transizione
  transitionProgress += 0.02; // Velocità della transizione
  if (transitionProgress >= 1) {
    transitionProgress = 0; // Riparti con una nuova transizione
    currentImage = nextImage; // L'immagine successiva diventa la corrente
    nextImage = loadImage("image" + int(random(1, 3)) + ".jpg"); // Carica una nuova immagine
    nextImage.resize(width, height);
  }
}
