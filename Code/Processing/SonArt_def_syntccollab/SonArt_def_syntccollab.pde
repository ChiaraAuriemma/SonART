import java.net.*;
import java.io.*;
import java.util.*;
import java.awt.image.BufferedImage;
import java.util.Base64;
import javax.imageio.ImageIO;

// === Variabili principali ===
PImage[] imgs;
int currentIndex = 0;
int nextIndex;
int cols, rows;
int spacing = 9;
Particle[][] particles;
float transitionProgress = 0;
boolean transitioning = false;

TCPImageReceiver tcpReceiver;

void setup() {
  //size(1200, 800);
  fullScreen();
  smooth();
  frameRate(60);

  // Setup TCP receiver
  tcpReceiver = new TCPImageReceiver(12345);

  // Setup particelle
  cols = width / spacing;
  rows = height / spacing;
  particles = new Particle[cols][rows];

  PImage initImage = createImage(width, height, RGB);
  initImage.loadPixels();
  for (int i = 0; i < initImage.pixels.length; i++) {
    initImage.pixels[i] = color(0);
  }
  initImage.updatePixels();

  imgs = new PImage[10];
  imgs[0] = initImage;

  initParticles(imgs[0]);
}

void draw() {
  background(255, 255, 255, 10); // "Nebbia"

  tcpReceiver.checkForNewImage();

  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      Particle p = particles[x][y];
      p.update();
      p.display();
    }
  }

  if (transitioning) {
    transitionProgress += 0.005;
    if (transitionProgress >= 1) {
      transitionProgress = 0;
      transitioning = false;
      currentIndex = nextIndex;
      //initParticles(imgs[currentIndex]);
    }
  }

  ScheduledImage scheduled = tcpReceiver.getNextImageIfReady();
  if (scheduled != null) {
    println("🖼️ Avvio transizione da coda");
    nextIndex = (currentIndex + 1) % imgs.length;
    imgs[nextIndex] = scheduled.img;
    assignNextTargets(scheduled.img);
    transitioning = true;
  }
}

void initParticles(PImage img) {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = i * spacing;
      int y = j * spacing;
      color c = img.get(x, y);
      particles[i][j] = new Particle(x, y, c);
    }
  }
}

void assignNextTargets(PImage nextImg) {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = i * spacing;
      int y = j * spacing;
      color newC = nextImg.get(x, y);
      particles[i][j].setNext(x, y, newC);
    }
  }
}
