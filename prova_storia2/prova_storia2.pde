PImage imgBackground;  // Immagine di sfondo
PImage imgLayer1;      // Prima immagine per il secondo layer
PImage imgLayer2;      // Seconda immagine per il secondo layer
ArrayList<BackgroundParticle> bgParticles = new ArrayList<BackgroundParticle>();  // Particelle dello sfondo
ArrayList<ImageParticle> imgParticles = new ArrayList<ImageParticle>();  // Particelle del secondo layer (immagine)
int particleCount = 22000;  // Numero di particelle dello sfondo
int imageParticleCount = 2000;  // Numero di particelle per il secondo layer
PGraphics layer1;  // Primo layer per lo sfondo
PGraphics layer2;  // Secondo layer per le particelle dell'immagine

float transition = 0;  // Variabile di interpolazione per la transizione tra le due immagini del secondo layer
float transitionSpeed = 0.01;  // Velocità di transizione

void setup() {
  size(1400, 800);  // Dimensione del canvas
  
  // Carica le immagini
  imgBackground = loadImage("background1.jpg");  // Immagine per lo sfondo
  imgLayer1 = loadImage("barca.png");  // Prima immagine per il secondo layer
  imgLayer2 = loadImage("image4.png");  // Seconda immagine per il secondo layer
  imgBackground.resize(width, height);
  imgLayer1.resize(width, height);
  imgLayer2.resize(width, height);
  
  // Crea le particelle per il primo layer (sfondo)
  for (int i = 0; i < particleCount; i++) {
    float x = random(width);
    float y = random(height);
    int c = imgBackground.get((int)x, (int)y);  // Colore preso dall'immagine di sfondo
    bgParticles.add(new BackgroundParticle(x, y, c));  // Aggiungi particella
  }

  // Crea le particelle per il secondo layer (immagine)
  for (int i = 0; i < imageParticleCount; i++) {
    float x = random(width);
    float y = random(height);
    int c = imgLayer1.get((int)x, (int)y);  // Colore preso dalla prima immagine
    imgParticles.add(new ImageParticle(x, y, c, imgLayer2.get((int)x, (int)y)));  // Aggiungi particella per il secondo layer
  }
  
  // Crea due layer separati per gestire i disegni
  layer1 = createGraphics(width, height);  // Layer per lo sfondo
  layer2 = createGraphics(width, height);  // Layer per il secondo gruppo di particelle
}

void draw() {
  // Aggiornamento della transizione
  transition += transitionSpeed;
  if (transition > 1) {
    transition = 1;  // Limita la transizione a 1 per non oltrepassare
  }

  // Layer 1: Particelle dello sfondo
  layer1.beginDraw();
  layer1.clear();  // Pulisce il layer ad ogni frame
  for (BackgroundParticle p : bgParticles) {
    p.update();  // Aggiorna la posizione
    p.display();  // Disegna la particella
  }
  layer1.endDraw();

  // Layer 2: Particelle che formano l'immagine
  layer2.beginDraw();
  layer2.clear();  // Pulisce il layer ad ogni frame
  
  // Aggiorna la posizione delle particelle nel secondo layer per formare l'immagine
  for (int i = 0; i < imgParticles.size(); i++) {
    ImageParticle p = imgParticles.get(i);
    
    // Interpola il colore tra le due immagini
    int color1 = p.color1;
    int color2 = p.color2;
    color col = lerpColor(color1, color2, transition);
    
    p.update();  // Movimento delle particelle
    p.display(col);  // Disegna la particella con il colore interpolato
  }
  
  layer2.endDraw();

  // Combinazione dei due layer nel canvas principale
  background(255);  // Sfondo bianco del canvas principale
  image(layer1, 0, 0);  // Mostra il primo layer (sfondo con particelle grandi)
  image(layer2, 0, 0);  // Mostra il secondo layer (particelle che formano l'immagine)
}

// Classe per le particelle dello sfondo (oscillazione sul posto)
class BackgroundParticle {
  float x, y;   // Posizione attuale
  float baseX, baseY; // Posizione di origine (dove è stata creata la particella)
  int col;      // Colore della particella
  float angle;  // Angolo per oscillazione

  BackgroundParticle(float x, float y, int col) {
    this.x = x;
    this.y = y;
    this.baseX = x; // La posizione di origine rimane fissa
    this.baseY = y; // La posizione di origine rimane fissa
    this.col = col; // Colore preso dall'immagine
    this.angle = random(TWO_PI);  // Angolo iniziale casuale per l'oscillazione
  }

  void update() {
    angle += 0.09;  // Velocità di oscillazione
    x = baseX + sin(angle) * 15;  // Oscillazione orizzontale attorno al punto baseX
    y = baseY + cos(angle) * 15;  // Oscillazione verticale attorno al punto baseY
  }

  void display() {
    noStroke();  
    fill(col); // Colore della particella senza trasparenza
    
    // Disegna una forma ovale allungata
    pushMatrix();
    translate(x, y);  // Sposta il punto di disegno sulla posizione aggiornata
    rotate(angle);  // Ruota la particella per aggiungere varietà
    ellipse(0, 0, 10, 25);  // Forma ovale allungata
    popMatrix();
  }
}

// Classe per le particelle del secondo layer (che formano un'immagine)
class ImageParticle {
  float x, y;
  int color1, color2; // Colori per la transizione
  float targetX, targetY;  // Posizione target per la particella (per formare l'immagine)
  float speedTransition;  // Velocità della transizione

  ImageParticle(float x, float y, int color1, int color2) {
    this.x = x;
    this.y = y;
    this.color1 = color1;
    this.color2 = color2;
    this.targetX = x;  // Partiamo dalla posizione attuale
    this.targetY = y;  // Partiamo dalla posizione attuale
    this.speedTransition = 0.05; // Velocità di transizione verso la nuova posizione
  }

  void update() {
    // Interpola la posizione della particella verso il target (immagine)
    x += (targetX - x) * speedTransition;
    y += (targetY - y) * speedTransition;
  }

  void display(color c) {
    noStroke();
    fill(c, 150);  // Colore interpolato tra le due immagini con trasparenza
    ellipse(x, y, 5, 5);  // Particella di piccole dimensioni
  }
}
