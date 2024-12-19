PImage img1, img2;  // Le due immagini di base
int particleCount = 15000;  // Numero di particelle di sfondo

PGraphics layer1;  // Primo layer per lo sfondo di particelle
PGraphics layer2;  // Secondo layer per le particelle che formano l'immagine sopra lo sfondo

BackgroundLayer bgLayer;  // Oggetto per gestire il background
ImageLayer imageLayer;  // Oggetto per gestire il layer dell'immagine

void setup() {
  size(1400, 800);  // Dimensione del canvas principale

  // Crea i layer separati per gestire le particelle
  layer1 = createGraphics(width, height);  // Layer per il primo gruppo di particelle (sfondo)
  layer2 = createGraphics(width, height);  // Layer per il secondo gruppo di particelle (immagine sopra)

  img1 = loadImage("background1.jpg");  // Carica l'immagine per lo sfondo
  img2 = loadImage("image1.png");  // Carica l'immagine più piccola per il secondo layer

  img1.resize(width, height);  // Ridimensiona l'immagine per adattarla al canvas
  img2.resize(width / 4, height / 4);  // Ridimensiona l'immagine per farla apparire più piccola

  // Crea gli oggetti per i layer
  bgLayer = new BackgroundLayer(img1, particleCount);  // Crea il layer di sfondo
  imageLayer = new ImageLayer(img2, 700, 400);  // Crea il layer dell'immagine
}

void draw() {
  // Layer 1: Particelle di sfondo (gestito dalla classe BackgroundLayer)
  layer1.beginDraw();
  layer1.background(0, 10);  // Fondo trasparente per lo sfondo
  bgLayer.updateAndDisplay(layer1);  // Aggiorna e disegna le particelle nel layer di sfondo
  layer1.endDraw();

  // Layer 2: Particelle che formano l'immagine sopra lo sfondo (gestito dalla classe ImageLayer)
  layer2.beginDraw();
  layer2.clear();  // Pulisce il layer prima di disegnare
  imageLayer.updateAndDisplay(layer2);  // Aggiorna e disegna le particelle nel layer dell'immagine
  layer2.endDraw();

  // Unisci i due layer nel canvas principale
  image(layer1, 0, 0);  // Mostra il primo layer (sfondo di particelle)
  image(layer2, 0, 0);  // Mostra il secondo layer (particelle che formano l'immagine sopra)
}
