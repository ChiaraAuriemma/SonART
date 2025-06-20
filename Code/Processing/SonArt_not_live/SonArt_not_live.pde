import java.net.*;
import java.io.*;
import java.util.*;
import java.awt.image.BufferedImage;
import java.util.Base64;
import javax.imageio.ImageIO;

PImage[] imgs;
int currentIndex = 0;

int cols, rows;
int spacing = 9;

Particle[][] particles;

float transitionProgress = 0;
boolean transitioning = false;

int transitionStartTime = 0;
int transitionDuration = 0;

TCPImageReceiver tcpReceiver;

color[][] pendingColors;
volatile boolean readyForAssign = false;

ScheduledImage currentImage = null;

Queue<ScheduledImage> imageQueue = new LinkedList<>();

int startTime = -1;     // quando inizia la sequenza
int virtualTime = 0;

void setup() {
  size(1200, 800);
  smooth();
  frameRate(60);

  tcpReceiver = new TCPImageReceiver(12345);

  cols = width / spacing;
  rows = height / spacing;

  particles = new Particle[cols][rows];
  pendingColors = new color[cols][rows];
  imgs = new PImage[10];

  PImage initImage = createImage(width, height, RGB);
  initImage.loadPixels();
  Arrays.fill(initImage.pixels, color(0));
  initImage.updatePixels();

  imgs[0] = initImage;

  initParticles(initImage);
}

void draw() {
  background(255, 255, 255, 10);
  tcpReceiver.checkForNewImage();

  while (tcpReceiver.hasImages()) {
    imageQueue.add(tcpReceiver.nextImageFromQueue());
  }

  if (startTime < 0 && !imageQueue.isEmpty()) {
    startTime = millis();
    println("⏱️ Timer virtuale avviato a " + startTime);
  }

  if (startTime >= 0) {
    virtualTime = millis() - startTime;
  }

  if (currentImage == null && !imageQueue.isEmpty()) {
    currentImage = imageQueue.poll();
    imgs[currentIndex] = currentImage.img;
  
    // ⚡️ Inizializzazione dei particle sulla prima immagine
    initParticles(currentImage.img);
  
    println("📥 Prima immagine caricata e inizializzata: timestamp " + currentImage.timestamp);
  }

  if (!transitioning && !imageQueue.isEmpty() && currentImage != null) {
    ScheduledImage nextImage = imageQueue.peek();
    if (nextImage != null) {
      int estimatedDuration = nextImage.timestamp - currentImage.timestamp;
      if (estimatedDuration < 100) estimatedDuration = 100;

      // Avvia la transizione quando mancano estimatedDuration ms al timestamp dell’immagine
      if (virtualTime >= nextImage.timestamp - estimatedDuration) {
        imageQueue.poll();
        startTransition(nextImage);
      }
    }
  }

  if (readyForAssign) {
    applyPendingColors();
    readyForAssign = false;
  }

  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      Particle p = particles[x][y];
      p.update(transitioning, transitionProgress, transitionDuration);
      p.display();
    }
  }

  if (transitioning) {
    int now = millis();
    int elapsed = now - transitionStartTime;

    transitionProgress = constrain(elapsed / (float)transitionDuration, 0, 1);
    if (transitionProgress >= 1) {
      transitioning = false;
      currentIndex = (currentIndex + 1) % imgs.length;
      imgs[currentIndex] = currentImage.img;
    }
  }
}

void startTransition(ScheduledImage scheduled) {
  println("▶️ Avvio nuova transizione immagine con timestamp " + scheduled.timestamp);

  imgs[(currentIndex + 1) % imgs.length] = scheduled.img;

  new Thread(() -> {
    extractColorsInto(scheduled.img, pendingColors);
    readyForAssign = true;
  }).start();

  int estimatedDuration = scheduled.timestamp - currentImage.timestamp;
  if (estimatedDuration < 100) estimatedDuration = 100;

  transitionDuration = estimatedDuration;
  transitionStartTime = millis();
  transitionProgress = 0;
  transitioning = true;

  currentImage = scheduled;

  println("▶️ Durata transizione: " + transitionDuration + " ms");
}

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

void applyPendingColors() {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      particles[i][j].setNext(i * spacing, j * spacing, pendingColors[i][j]);
    }
  }
}

void extractColorsInto(PImage img, color[][] dest) {
  img.loadPixels();
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = i * spacing, y = j * spacing;
      dest[i][j] = img.pixels[y * img.width + x];
    }
  }
}
