// Import delle librerie Java per networking e gestione immagini
import java.io.*;
import java.net.*;
import java.util.Base64;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;

// === Variabili per la comunicazione server ===
ServerSocket server;         // Server TCP in ascolto sulla porta 12345
Socket client;               // Socket connesso al client
BufferedReader reader;       // Lettore del flusso di input (testo) del client
Thread receiverThread;       // Thread separato per ricevere dati senza bloccare draw()

// === Immagini ===
PImage currentImage, nextImage;  // Immagine corrente e prossima per la transizione

// === Matrice di particelle ===
Particle[][] particles;      // Particelle organizzate in griglia 2D

// === Transizione ===
float transitionProgress = 0;  // Avanzamento della transizione (da 0 a 1)
boolean isTransitioning = false;  // Flag per indicare se è in corso la transizione

// === Configurazione griglia di particelle ===
int spacing = 9;             // Distanza tra le particelle
int cols, rows;              // Numero di colonne e righe della griglia

void setup() {
  size(1400, 800);           // Dimensioni finestra
  frameRate(60);             // FPS
  smooth();                  // Antialiasing

  // === Creazione server TCP ===
  try {
    server = new ServerSocket(12345);  // In ascolto sulla porta 12345
    println("Server in ascolto sulla porta 12345...");
  } catch (IOException e) {
    println("Errore nella creazione del server: " + e.getMessage());
  }

  // === Immagine iniziale: tutta nera ===
  currentImage = createImage(width, height, RGB);
  currentImage.loadPixels();
  for (int i = 0; i < currentImage.pixels.length; i++) {
    currentImage.pixels[i] = color(0);  // Tutti i pixel neri
  }
  currentImage.updatePixels();
  nextImage = currentImage.copy();  // nextImage è uguale all'inizio

  //Setup della griglia
  cols = width / spacing;   // Quante colonne nella griglia
  rows = height / spacing;  // Quante righe
  particles = new Particle[cols][rows];  // Inizializza array
  initParticles(currentImage);           // Crea particelle a partire dall'immagine

  startReceiverThread();    // Avvia il thread che ascolta nuove immagini
}

void draw() {
  background(255, 255, 255, 10); // Sfondo bianco semi-trasparente (effetto pittura)

  // === Aggiorna e disegna ogni particella ===
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      Particle p = particles[i][j];
      p.update();   // Muove la particella
      p.display();  // La disegna sullo schermo
    }
  }

  //Gestione transizione
  if (isTransitioning) {
    transitionProgress += 0.02;   // Avanza la transizione
    if (transitionProgress >= 1) {
    transitionProgress = 0;
    isTransitioning = false;
    currentImage = nextImage.copy();  // ✅ aggiorna immagine di riferimento
    // non ricreare le particelle
}
  }
}

//Inizializza particelle a partire da un'immagine
void initParticles(PImage img) {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = i * spacing;
      int y = j * spacing;
      color c = img.get(x, y);     // Colore del pixel allineato alla griglia
      particles[i][j] = new Particle(x, y, c);  // Crea nuova particella
    }
  }
}

//Imposta obiettivi (target) per la transizione
void assignNextTargets(PImage img) {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = i * spacing;
      int y = j * spacing;
      color c = img.get(x, y);      // Nuovo colore
      particles[i][j].setNext(x, y, c);  // Imposta obiettivo per la particella
    }
  }
}

//Thread per ricevere immagini da un client
void startReceiverThread() {
  receiverThread = new Thread(new Runnable() {
    public void run() {
      try {
        client = server.accept();  // Attende connessione del client
        reader = new BufferedReader(new InputStreamReader(client.getInputStream()));
        println("Client connesso.");

        while (true) {
          // === Legge i dati Base64 fino a trovare <END> ===
          StringBuilder base64Builder = new StringBuilder();
          String line;
          while ((line = reader.readLine()) != null) {
            if (line.contains("<END>")) {
              base64Builder.append(line.replace("<END>", ""));  // Rimuove <END>
              break;
            }
            base64Builder.append(line);
          }

          // === Decodifica stringa Base64 in immagine ===
          String base64String = base64Builder.toString();
          if (!base64String.isEmpty()) {
            byte[] imageBytes = Base64.getDecoder().decode(base64String); // byte array
            ByteArrayInputStream bais = new ByteArrayInputStream(imageBytes); // stream
            BufferedImage bufferedImage = ImageIO.read(bais);  // Java immagine

            // === Converte BufferedImage in PImage (Processing) ===
            if (bufferedImage != null) {
              PImage received = new PImage(bufferedImage.getWidth(), bufferedImage.getHeight());
              received.loadPixels();
              bufferedImage.getRGB(0, 0, bufferedImage.getWidth(), bufferedImage.getHeight(), received.pixels, 0, bufferedImage.getWidth());
              received.updatePixels();
              received.resize(width, height);  // Adatta alle dimensioni del canvas

              println("Immagine ricevuta, avvio transizione");
              nextImage = received.copy();       // Salva la nuova immagine
              assignNextTargets(nextImage);     // Imposta le particelle verso la nuova immagine
              isTransitioning = true;           // Inizia transizione
              transitionProgress = 0;
            }
          }
        }

      } catch (IOException e) {
        println("⚠️ Errore nella ricezione immagine: " + e.getMessage());
      }
    }
  });
  receiverThread.start();  // Avvia il thread
}
