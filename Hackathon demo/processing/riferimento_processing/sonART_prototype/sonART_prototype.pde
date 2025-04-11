PImage currentImage, nextImage;
ArrayList<Particle> particles;
float transitionProgress = 0; // Avanza gradualmente da 0 a 1 per la transizione
int currentImageIndex = 0; // Indice dell'immagine corrente

// Configurazione delle immagini (percorso, posizione X, posizione Y, larghezza, altezza)
String[] imagePaths = {"background1.jpg", "gabbiano.png", "ali.png", "petrolio.png", "strada.png", "gatto.png", "cuore.png", "uovo.png", "gatto.png", "campana.png", "gabbiano.png"};
float[][] imagePositions = {
  {0, 0, 1400, 800},      // Prima immagine: tutto schermo
  {100, 100, 800, 600},   // Seconda immagine: in alto a sinistra
  {-400, -200, 1000, 600},  // Terza immagine: centrata
  {200, 0, 900, 500},
  {0, 0, 1400, 800}, 
  {200, 300, 900, 500},
  
   {0, 0, 1400, 800}, 
  {200, 300, 900, 500},
  {800, 300, 900, 500},
  {0, 0, 1000, 600}, 
  {200, 300, 900, 500},
  // Quarta immagine: personalizzata
};

// Variabili per la posizione e la dimensione delle immagini
float currentX, currentY, currentWidth, currentHeight;
float nextX, nextY, nextWidth, nextHeight;

void setup() {
  size(1400, 800);
  loadCurrentAndNextImages();

  particles = new ArrayList<Particle>();
  for (int i = 0; i < 15000; i++) {
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
  if (transitionProgress > 0) {
    transitionProgress += 0.01; // Velocità della transizione
    if (transitionProgress >= 1) {
      transitionProgress = 0; // Reset della transizione

      // L'immagine successiva diventa la corrente
      currentImage = nextImage;
      currentX = nextX;
      currentY = nextY;
      currentWidth = nextWidth;
      currentHeight = nextHeight;

      // Aggiorna l'indice e carica la prossima immagine
      currentImageIndex = (currentImageIndex + 1) % imagePaths.length;
      loadCurrentAndNextImages();
    }
  }
}

void keyPressed() {
  if (key == 'p' || key == 'P') {
    if (transitionProgress == 0) {
      transitionProgress = 0.01; // Inizia la transizione
    }
  }
}

void loadCurrentAndNextImages() {
  currentImage = loadImage(imagePaths[currentImageIndex]);
  int nextIndex = (currentImageIndex + 1) % imagePaths.length;
  nextImage = loadImage(imagePaths[nextIndex]);

  // Posizione e dimensioni dell'immagine corrente
  currentX = imagePositions[currentImageIndex][0];
  currentY = imagePositions[currentImageIndex][1];
  currentWidth = imagePositions[currentImageIndex][2];
  currentHeight = imagePositions[currentImageIndex][3];
  currentImage.resize((int)currentWidth, (int)currentHeight);

  // Posizione e dimensioni della prossima immagine
  nextX = imagePositions[nextIndex][0];
  nextY = imagePositions[nextIndex][1];
  nextWidth = imagePositions[nextIndex][2];
  nextHeight = imagePositions[nextIndex][3];
  nextImage.resize((int)nextWidth, (int)nextHeight);
}
