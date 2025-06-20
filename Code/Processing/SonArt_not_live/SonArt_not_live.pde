import java.util.concurrent.*;
import java.util.*;
import java.io.*;
import java.net.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

PImage[] imgs;
int cols, rows;
int spacing = 9;

Particle[][] particles;

TCPImageReceiver tcpReceiver;
ExecutorService imageProcessor;

ConcurrentLinkedQueue<ScheduledImage> imageQueue = new ConcurrentLinkedQueue<>();
ScheduledImage currentImage = null;

color[][] pendingColors;
volatile boolean readyForAssign = false;

int startTime = -1;
int virtualTime = 0;

boolean transitioning = false;
float transitionProgress = 0;
int transitionDuration = 0;
int transitionStartTime = 0;

int currentIndex = 0;
float lastTime = 0; 

void setup() {
  fullScreen(P2D);  // Avvia a schermo intero
  smooth();
  frameRate(60);
  
  lastTime = millis() / 1000.0;  // tempo in secondi

  cols = width / spacing;
  rows = height / spacing;
  println("Resolution: " + width + " x " + height + " => cols=" + cols + ", rows=" + rows);

  tcpReceiver = new TCPImageReceiver(12345);
  imageProcessor = Executors.newSingleThreadExecutor();

  imgs = new PImage[10];
  imgs[0] = createImage(width, height, RGB);
  imgs[0].loadPixels();
  Arrays.fill(imgs[0].pixels, color(0));
  imgs[0].updatePixels();

  particles = new Particle[cols][rows];
  initParticles(imgs[0]);
  pendingColors = new color[cols][rows];

  // Ricezione immagini in thread separato
  new Thread(() -> {
    while (true) {
      ScheduledImage img = tcpReceiver.nextImageBlocking();
      imageProcessor.submit(() -> {
        PImage scaled = img.img.copy();
        scaled.resize(width, height); // 🔄 ridimensiona al fullscreen
        color[][] buffer = new color[cols][rows];
        extractColorsInto(scaled, buffer);
        img.precomputedColors = buffer;
        imageQueue.add(img);
        println("Enqueued image with timestamp " + img.timestamp);
      });
    }
  }).start();
}

void draw() {
  background(255, 255, 255, 10);
  
  float currentTime = millis() / 1000.0;
  float dt = currentTime - lastTime;  // tempo trascorso dall'ultimo frame in secondi
  lastTime = currentTime;

  if (startTime < 0 && !imageQueue.isEmpty()) {
    startTime = millis();
  }
  if (startTime >= 0) {
    virtualTime = millis() - startTime;
  }

  // Avvio prima transizione
  if (currentImage == null && !imageQueue.isEmpty()) {
    ScheduledImage first = imageQueue.peek();
    if (virtualTime >= first.timestamp) {
      imageQueue.poll();
      pendingColors = first.precomputedColors;
      readyForAssign = true;
      currentImage = first;
      startTransitionFromBlack(first);
    }
  }

  // Transizione successiva
  if (!transitioning && !imageQueue.isEmpty() && currentImage != null) {
    ScheduledImage next = imageQueue.peek();
    int estimatedDuration = max(next.timestamp - currentImage.timestamp, 100);

    // Cambiato da '==' a '>=' per avviare la transizione
    if (virtualTime >= next.timestamp - estimatedDuration) {
      println("Starting transition: virtualTime=" + virtualTime + ", next.timestamp=" + next.timestamp + ", estimatedDuration=" + estimatedDuration);
      imageQueue.poll();
      pendingColors = next.precomputedColors;
      readyForAssign = true;
      startTransition(next);
      currentImage = next;
    }
  }

  if (readyForAssign) {
    applyPendingColors();
    readyForAssign = false;
  }

  // Aggiorna e disegna particelle
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      particles[x][y].update(transitioning, transitionProgress, transitionDuration, dt);
      particles[x][y].display();
    }
  }

  if (transitioning) {
    int elapsed = millis() - transitionStartTime;
    transitionProgress = constrain(elapsed / (float)transitionDuration, 0, 1);
    if (transitionProgress >= 1) {
      transitioning = false;
      currentIndex = (currentIndex + 1) % imgs.length;
      imgs[currentIndex] = currentImage.img;
    }
  }
}

// Avvia transizione da nero con durata fissa
void startTransitionFromBlack(ScheduledImage img) {
  transitionDuration = 2000;  // Durata fissa 2 secondi
  transitionStartTime = millis();
  transitionProgress = 0;
  transitioning = true;
}

// Avvia transizione tra immagini
void startTransition(ScheduledImage img) {
  int estimatedDuration = max(img.timestamp - currentImage.timestamp, 100);
  transitionDuration = estimatedDuration;
  transitionStartTime = millis();
  transitionProgress = 0;
  transitioning = true;
}

// Inizializza le particelle nere
void initParticles(PImage img) {
  img.loadPixels();
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = i * spacing, y = j * spacing;
      color c = img.pixels[y * img.width + x];
      particles[i][j] = new Particle(x, y, c);
    }
  }
}

// Applica i colori pending
void applyPendingColors() {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      particles[i][j].setNext(i * spacing, j * spacing, pendingColors[i][j]);
    }
  }
}

// Estrae i colori da un’immagine
void extractColorsInto(PImage img, color[][] dest) {
  img.loadPixels();
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = i * spacing, y = j * spacing;
      dest[i][j] = img.pixels[y * img.width + x];
    }
  }
}
