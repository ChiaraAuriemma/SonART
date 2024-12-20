PImage currentImage, nextImage;
ArrayList<Particle> particles;
float transitionProgress = 0; // Avanza gradualmente da 0 a 1 per la transizione
int currentImageIndex = 0; // Indice dell'immagine corrente
String[] imagePaths = {"image1.jpg", "image2.jpg", "image3.jpg", "image4.jpg", "image5.jpg", "image6.jpg", "image7.jpg"}; // Percorsi delle immagini

void setup() {
  size(1400, 800);
  currentImage = loadImage(imagePaths[currentImageIndex]);
  nextImage = loadImage(imagePaths[(currentImageIndex + 1) % imagePaths.length]);
  currentImage.resize(width, height);
  nextImage.resize(width, height);

  particles = new ArrayList<Particle>();
  for (int i = 0; i < 20000; i++) {
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

    // Passa all'immagine successiva
    currentImageIndex = (currentImageIndex + 1) % imagePaths.length;
    currentImage = nextImage; // L'immagine successiva diventa la corrente
    nextImage = loadImage(imagePaths[(currentImageIndex + 1) % imagePaths.length]); // Carica l'immagine successiva
    nextImage.resize(width, height);
  }
}
