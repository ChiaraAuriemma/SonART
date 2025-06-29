//--- IMPORT LIBRARIES ---
import java.util.concurrent.*;
import java.util.*;
import java.io.*;
//TCP connection
import java.net.*;

//image
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

//audio
import ddf.minim.*;
import javax.sound.sampled.*;

//--- SET VARIABLES --- 
PImage[] imgs; 
int cols, rows;
int spacing = 9;

Particle[][] particles;

//TCP image/audio receiver from TCPImageReceiverAndAudio class
TCPImageReceiverAndAudio tcpReceiver; 

ExecutorService imageProcessor;

//list of processed images
List<ScheduledImage> processedImages;  

//Currently displayed image
ScheduledImage currentImage = null;

 // Buffer for new particles color
color[][] pendingColors;
volatile boolean readyForAssign = false; //new color availability

//variable for time management
int startTime = -1;
int virtualTime = 0; //used for synch immages and audio

//variable for transition management
boolean transitioning = false;
float transitionProgress = 0;
float transitionDuration = 0;   
int transitionStartTime = 0;    

float lastTime = 0;

//file audio management 
Minim minim; 
AudioPlayer player;
Clip clip; 

boolean audioReady = false;
boolean audioStarted = false;


//--- SETUP ---
void setup() {
  fullScreen(P2D, 2);
  smooth();
  frameRate(60);

  lastTime = millis() / 1000.0;

  cols = width / spacing;
  rows = height / spacing;
  
  //Initialize Minim
  minim = new Minim(this);
  
  //Connection to TCP port
  tcpReceiver = new TCPImageReceiverAndAudio(12345, minim);
  
  //create Thread for image processor
  imageProcessor = Executors.newSingleThreadExecutor();
  processedImages = Collections.synchronizedList(new ArrayList<>());
  
  //creation a black particles image
  imgs = new PImage[10];
  imgs[0] = createImage(width, height, RGB);
  imgs[0].loadPixels();
  Arrays.fill(imgs[0].pixels, color(0));
  imgs[0].updatePixels();
  
  particles = new Particle[cols][rows];
  initParticles(imgs[0]);
  pendingColors = new color[cols][rows];
  
  
  // THREAD: Receive images from TCP and preprocess
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

  // THREAD: Wait until audio is ready
  new Thread(() -> {
    while (true) {
      if (tcpReceiver.player != null && !audioReady) {
        player = tcpReceiver.player;
        audioReady = true;
        println("[DEBUG] Audio pronto per la riproduzione");
      }
      if (tcpReceiver.clip != null && !audioReady){
        clip = tcpReceiver.clip;
        audioReady = true;
        println("[DEBUG] Audio pronto per la riproduzione");
      }
      
      delay(100); //avoid busy waiting 
    }
  }).start();
}


//--- DRAW ---
void draw() {
  background(255, 255, 255, 10);

  float currentTime = millis() / 1000.0;
  float dt = currentTime - lastTime;
  lastTime = currentTime;
 
 
  //Audio start when it's ready and when the image queue is not empty 
  if (startTime < 0) {
    synchronized(processedImages) {
      if (!processedImages.isEmpty() && audioReady && !audioStarted) {
        startTime = millis();  // inizio ora
        if(tcpReceiver.extention == 0){
          player.play(); // Minim-based audio for MP£ file
          audioStarted = true;
          println("[DEBUG] Audio avviato, startTime = " + startTime);
        }else{
          clip.start(); // Java Sound Clip for WAV file
          audioStarted = true;
          println("[DEBUG] Audio avviato, startTime = " + startTime);
        }
      }
    }
  }

  
  if (startTime >= 0){
    virtualTime = millis() - startTime; //if audio started set the virtual time
  } else {
    virtualTime = 0;
  }
 
  //print next timestamp
  synchronized(processedImages){
    if (!processedImages.isEmpty()) {
      println("[DEBUG] Next image timestamp = " + processedImages.get(0).timestamp);
    }
  }
  
  //image transition
  synchronized(processedImages) {
    // Se non c'è immagine corrente e abbiamo immagini da mostrare (prima immagine)
    if (currentImage == null && !processedImages.isEmpty()) {
      ScheduledImage first = processedImages.get(0);
      
      if(first.timestamp == 0) {
        // Salto la transizione e assegno subito l'immagine e i colori
        currentImage = first;
        pendingColors = first.precomputedColors;
        readyForAssign = true;
    
        transitioning = false;
        transitionProgress = 1.0f;  // transizione "completa"
        transitionDuration = 0;
    
        processedImages.remove(0);
    
        println("[DEBUG] Primo timestamp 0, salto transizione e assegno immagine subito");
      }else {
        // Assicuriamoci che il timestamp minimo sia almeno 500 ms per evitare problemi
        //int safeTimestamp = max(first.timestamp, 500);
        int safeTimestamp = first.timestamp; 
    
        int transitionDurationFirst = safeTimestamp / 3; // 30% della durata totale
        int transitionStartThresholdFirst = safeTimestamp - transitionDurationFirst;
    
        if (!transitioning && virtualTime >= transitionStartThresholdFirst) {
          transitioning = true;
    
          transitionStartTime = transitionStartThresholdFirst;  // uso virtualTime coerente
          transitionDuration = transitionDurationFirst;
    
          // NON rimuoviamo la prima immagine dalla lista, la lasciamo per sicurezza
          pendingColors = first.precomputedColors;
          readyForAssign = true;
          currentImage = first;
          transitionProgress = 0;
          
          processedImages.remove(0);
    
          println("[DEBUG] Inizio transizione PRIMA immagine a virtualTime=" + virtualTime + " ms, timestamp=" + first.timestamp);
        }
      }
    } 
    // Transizioni successive
    else if (!transitioning && !processedImages.isEmpty() && currentImage != null) {
      ScheduledImage next = processedImages.get(0);
      int interval = next.timestamp - currentImage.timestamp;
  
      if (interval <= 0) {
        println("[WARN] Interval nullo o negativo, rimuovo immagine corrotta");
        processedImages.remove(0);
        return;
      }
  
      int transitionDurationNext = (int)(interval * 0.3f);
      int transitionStartThreshold = next.timestamp - transitionDurationNext;
  
      if (virtualTime >= transitionStartThreshold) {
        transitioning = true;
  
        transitionStartTime = transitionStartThreshold;
        transitionDuration = transitionDurationNext;
  
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
    transitionProgress += dt / (transitionDuration / 1000.0);  // dt è in secondi, duration in ms
    transitionProgress = constrain(transitionProgress, 0, 1);
  
    if (transitionProgress >= 1) {
      transitioning = false;
      
      println("[DEBUG] Fine transizione a virtualTime=" + virtualTime + " ms, timestamp=" + currentImage.timestamp);
    }
  }
  /*
  if (transitioning) {
    int timetoend = currentImage.timestamp - virtualTime;
    int totalTransitionTime = currentImage.timestamp - transitionStartTime;
    if(totalTransitionTime > 0){
      transitionProgress = 1.0f - ((float)timetoend/(float)totalTransitionTime);
      transitionProgress = constrain(transitionProgress, 0, 1);
    }
    if(virtualTime >= currentImage.timestamp){
      transitioning = false;
      transitionProgress = 1.0f;
    }
  }*/

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
