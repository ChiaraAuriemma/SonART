// Import per la gestione TCP e file
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Base64;

// === Variabili principali ===
TCPReceiver tcpReceiver;
PImage[] imgs;
int currentIndex = 0;
int nextIndex;
int cols, rows;
int spacing = 9;
Particle[][] particles;
float transitionProgress = 0;
boolean transitioning = false;

void setup() {
  //size(1200, 800);
  fullScreen();
  smooth();
  frameRate(60);

  tcpReceiver = new TCPReceiver(12345);  // Porta in ascolto per connessioni TCP

  cols = width / spacing;
  rows = height / spacing;
  particles = new Particle[cols][rows];

  // Crea un'immagine nera per inizializzare
  PImage initImage = createImage(width, height, RGB);
  initImage.loadPixels();
  for (int i = 0; i < initImage.pixels.length; i++) {
    initImage.pixels[i] = color(0);  // Partenza da nero
  }
  initImage.updatePixels();

  imgs = new PImage[10];
  imgs[0] = initImage;

  initParticles(imgs[0]);
}

void draw() {
  background(255, 255, 255, 10); // Effetto "nebbioso" sfumato

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
  

  // Verifica se è arrivata una nuova immagine via TCP
  PImage received = tcpReceiver.checkForImage();
  if (received != null) {
    received.resize(width, height);
    nextIndex = (currentIndex + 1) % imgs.length;
    imgs[nextIndex] = received;
    assignNextTargets(received);
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
