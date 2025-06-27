import ddf.minim.*;
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

TCPImageReceiverAndAudio tcpReceiver;
ExecutorService imageProcessor;

List<ScheduledImage> processedImages;  // Lista sincronizzata per immagini processate
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

Minim minim;
AudioPlayer player;

boolean audioReady = false;
boolean audioStarted = false;

void setup() {
  fullScreen(P2D);
  smooth();
  frameRate(60);

  lastTime = millis() / 1000.0;

  cols = width / spacing;
  rows = height / spacing;
  println("Resolution: " + width + " x " + height + " => cols=" + cols + ", rows=" + rows);

  minim = new Minim(this);
  tcpReceiver = new TCPImageReceiverAndAudio(12345, minim);
  imageProcessor = Executors.newSingleThreadExecutor();

  processedImages = Collections.synchronizedList(new ArrayList<>());

  imgs = new PImage[10];
  imgs[0] = createImage(width, height, RGB);
  imgs[0].loadPixels();
  Arrays.fill(imgs[0].pixels, color(0));
  imgs[0].updatePixels();

  particles = new Particle[cols][rows];
  initParticles(imgs[0]);
  pendingColors = new color[cols][rows];

  // Thread che legge immagini da tcpReceiver, le elabora e salva in processedImages
  new Thread(() -> {
    while (true) {
      ScheduledImage img = tcpReceiver.nextImageBlocking();
      imageProcessor.submit(() -> {
        PImage scaled = img.img.copy();
        scaled.resize(width, height);
        color[][] buffer = new color[cols][rows];
        extractColorsInto(scaled, buffer);
        img.precomputedColors = buffer;
        synchronized(processedImages) {
          processedImages.add(img);
        }
      });
    }
  }).start();

  // Thread che controlla se audio è pronto
  new Thread(() -> {
    while (true) {
      if (tcpReceiver.player != null && !audioReady) {
        player = tcpReceiver.player;
        audioReady = true;
        println("[DEBUG] Audio pronto per la riproduzione");
      }
      delay(100);
    }
  }).start();
}

void draw() {
  background(255, 255, 255, 10);

  float currentTime = millis() / 1000.0;
  float dt = currentTime - lastTime;
  lastTime = currentTime;

  // Avvio audio e timer appena audio pronto e immagini pronte
  if (startTime < 0) {
    synchronized(processedImages) {
      if (!processedImages.isEmpty() && audioReady && !audioStarted) {
        startTime = millis();  // inizio ora
        player.play();
        audioStarted = true;
        println("[DEBUG] Audio avviato, startTime = " + startTime);
      }
    }
  }

  // Calcola virtualTime
  if (startTime >= 0) {
    virtualTime = millis() - startTime;
  } else {
    virtualTime = 0;
  }

  println("[DEBUG] virtualTime = " + virtualTime);
  synchronized(processedImages) {
    if (!processedImages.isEmpty()) {
      println("[DEBUG] Prossima immagine timestamp = " + processedImages.get(0).timestamp);
    }
  }

  synchronized(processedImages) {
    // Se non c'è immagine corrente e abbiamo immagini da mostrare (prima immagine)
    if (currentImage == null && !processedImages.isEmpty()) {
      ScheduledImage first = processedImages.get(0);
      int transitionDurationFirst = first.timestamp / 3; // 30% della durata totale
      int transitionStartThresholdFirst = first.timestamp - transitionDurationFirst;

      if (!transitioning && virtualTime >= transitionStartThresholdFirst) {
        transitioning = true;
        transitionStartTime = transitionStartThresholdFirst;  // assegnazione una tantum
        transitionDuration = transitionDurationFirst;         // assegnazione una tantum
        // Non rimuoviamo la prima immagine dalla lista, la lasciamo per sicurezza
        pendingColors = first.precomputedColors;
        readyForAssign = true;
        currentImage = first;
        transitionProgress = 0;
        println("[DEBUG] Inizio transizione PRIMA immagine a virtualTime=" + virtualTime + " ms, timestamp=" + first.timestamp);
      }
    } 
    // Transizioni successive
    else if (!transitioning && !processedImages.isEmpty() && currentImage != null) {
      ScheduledImage next = processedImages.get(0);
      int interval = next.timestamp - currentImage.timestamp;
      int transitionDurationNext = (int)(interval * 0.3f);
      int transitionStartThreshold = next.timestamp - transitionDurationNext;

      if (virtualTime >= transitionStartThreshold) {
        transitioning = true;
        transitionStartTime = transitionStartThreshold;  // assegnazione una tantum
        transitionDuration = transitionDurationNext;     // assegnazione una tantum
        processedImages.remove(0);  // rimuove immagine già in transizione
        pendingColors = next.precomputedColors;
        readyForAssign = true;
        currentImage = next;
        transitionProgress = 0;
        println("[DEBUG] Inizio transizione a virtualTime=" + virtualTime + " ms, timestamp=" + next.timestamp);
      }
    }
  }

  // Aggiorna il progresso della transizione
  if (transitioning) {
    int elapsed = virtualTime - transitionStartTime;
    transitionProgress = constrain((float) elapsed / transitionDuration, 0, 1);

    if (virtualTime >= currentImage.timestamp) {
      transitioning = false;
      transitionProgress = 1.0f;
      println("[DEBUG] Fine transizione a virtualTime=" + virtualTime + " ms, timestamp=" + currentImage.timestamp);
    }
  }

  // Applica i nuovi colori alle particelle se pronti
  if (readyForAssign) {
    applyPendingColors();
    readyForAssign = false;
  }

  // Aggiorna e disegna tutte le particelle
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
