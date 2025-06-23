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
float transitionDuration = 0;   // in milliseconds
int transitionStartTime = 0;    // in milliseconds

float lastTime = 0;

int nextTimestamp = 0;

// -----------------------------------------------------
void setup() {
  fullScreen(P2D);
  smooth();
  frameRate(60);

  lastTime = millis() / 1000.0;

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

  // Thread per ricezione immagini
  new Thread(() -> {
    while (true) {
      ScheduledImage img = tcpReceiver.nextImageBlocking();
      imageProcessor.submit(() -> {
        PImage scaled = img.img.copy();
        scaled.resize(width, height);
        color[][] buffer = new color[cols][rows];
        extractColorsInto(scaled, buffer);
        img.precomputedColors = buffer;
        imageQueue.add(img);
      });
    }
  }).start();
}

// -----------------------------------------------------
void draw() {
  background(255, 255, 255, 10);

  float currentTime = millis() / 1000.0;
  float dt = currentTime - lastTime;
  lastTime = currentTime;

  if (startTime < 0 && !imageQueue.isEmpty()) {
    startTime = millis();
  }

  if (startTime >= 0) {
    virtualTime = millis() - startTime;
  }

  // Prima immagine (inizio visualizzazione)
  if (currentImage == null && !imageQueue.isEmpty()) {
    ScheduledImage first = imageQueue.peek();
    if (virtualTime >= first.timestamp) {
      imageQueue.poll();
      pendingColors = first.precomputedColors;
      readyForAssign = true;
      currentImage = first;

      // Prima transizione da nero (50% del tempo fino a first.timestamp)
      transitionDuration = first.timestamp * 0.1f;
      transitionStartTime = virtualTime;
      transitioning = true;
      transitionProgress = 0;
      println("[DEBUG] Prima immagine visualizzata a virtualTime=" + virtualTime + " ms, timestamp previsto=" + first.timestamp);
  
    }
  }

  // Gestione transizione tra immagini successive
  if (!transitioning && !imageQueue.isEmpty() && currentImage != null) {
    ScheduledImage next = imageQueue.peek();
    int interval = next.timestamp - currentImage.timestamp;

    transitionDuration = interval * 0.1f;  // 50% come durata di transizione

    int transitionStartThreshold = next.timestamp - (int)transitionDuration;

    // Se siamo arrivati al punto di inizio transizione
    if (virtualTime >= transitionStartThreshold) {
      transitioning = true;
      transitionStartTime = transitionStartThreshold;  // Forza l'inizio transizione al momento corretto

      imageQueue.poll();
      pendingColors = next.precomputedColors;
      readyForAssign = true;
      currentImage = next;
      transitionProgress = 0;
      
      println("[DEBUG] Prima immagine visualizzata a virtualTime=" + virtualTime + " ms, timestamp previsto=" + next.timestamp);
    }
  }

  // Aggiorna progressione della transizione
  if (transitioning) {
    int elapsed = virtualTime - transitionStartTime;
    transitionProgress = constrain((float)elapsed / transitionDuration, 0, 1);

    if (elapsed >= transitionDuration) {
      transitioning = false;
      transitionProgress = 1.0f;
    }
  } else {
    transitionProgress = 1.0f;
  }

  if (readyForAssign) {
    applyPendingColors();
    readyForAssign = false;
  }

  // Aggiorna e disegna le particelle con la progressione di transizione
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      particles[x][y].update(transitioning, transitionProgress, dt);
      particles[x][y].display();
    }
  }
}

// -----------------------------------------------------
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

// -----------------------------------------------------
void applyPendingColors() {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      particles[i][j].setNext(i * spacing, j * spacing, pendingColors[i][j]);
    }
  }
}

// -----------------------------------------------------
void extractColorsInto(PImage img, color[][] dest) {
  img.loadPixels();
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = i * spacing, y = j * spacing;
      dest[i][j] = img.pixels[y * img.width + x];
    }
  }
}
