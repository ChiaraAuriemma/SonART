import java.io.*;
import java.net.*;
import java.util.Base64;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;

ServerSocket server;

PImage currentImage, nextImage;
ArrayList<Particle> particles;
float transitionProgress = 0;
boolean isTransitioning = false;

int numParticles = 8000;

void setup() {
  size(1400, 800);
  frameRate(60);

  // Server TCP
  try {
    server = new ServerSocket(12345);
    server.setSoTimeout(10); // Per evitare blocchi
    println("✅ Server in ascolto sulla porta 12345...");
  } catch (IOException e) {
    println("❌ Errore nella creazione del server: " + e.getMessage());
  }

  // Immagine nera iniziale
  currentImage = createImage(width, height, RGB);
  currentImage.loadPixels();
  for (int i = 0; i < currentImage.pixels.length; i++) {
    currentImage.pixels[i] = color(0);
  }
  currentImage.updatePixels();
  nextImage = currentImage.copy();

  // Particelle iniziali
  particles = new ArrayList<Particle>();
  for (int i = 0; i < numParticles; i++) {
    int x = int(random(currentImage.width));
    int y = int(random(currentImage.height));
    int col = getAverageColor(currentImage, x, y, 5);
    particles.add(new Particle(x, y, col));
  }
}

void draw() {
  background(255);

  // Ricezione immagine da client
  try {
    Socket client = server.accept();
    BufferedReader reader = new BufferedReader(new InputStreamReader(client.getInputStream()));
    String base64String = reader.readLine();

    if (base64String != null && !base64String.trim().isEmpty()) {
      byte[] imageBytes = Base64.getDecoder().decode(base64String);
      ByteArrayInputStream bais = new ByteArrayInputStream(imageBytes);
      BufferedImage bufferedImage = ImageIO.read(bais);

      if (bufferedImage != null) {
        PImage received = new PImage(bufferedImage.getWidth(), bufferedImage.getHeight());
        received.loadPixels();
        bufferedImage.getRGB(0, 0, bufferedImage.getWidth(), bufferedImage.getHeight(), received.pixels, 0, bufferedImage.getWidth());
        received.updatePixels();
        received.resize(width, height);

        println("📥 Nuova immagine ricevuta, avvio transizione");

        nextImage = received;
        startTransition();
        isTransitioning = true;
        transitionProgress = 0;
      }
    }

    reader.close();
    client.close();
  } catch (SocketTimeoutException e) {
    // nessuna connessione: è ok
  } catch (IOException e) {
    println("⚠️ Errore nella ricezione immagine: " + e.getMessage());
  }

  // Gestione transizione
  if (isTransitioning) {
    transitionProgress += 0.01;
    if (transitionProgress >= 1) {
      transitionProgress = 1;
      isTransitioning = false;
      currentImage = nextImage;
    }
  }

  // Aggiorna e disegna particelle
  for (Particle p : particles) {
    p.update();
    p.display();
  }
}

// Avvia transizione: imposta nuovi target alle particelle
void startTransition() {
  for (Particle p : particles) {
    int x = int(random(nextImage.width));
    int y = int(random(nextImage.height));
    int col = getAverageColor(nextImage, x, y, 5);
    p.setTarget(x, y, col);
  }
}

// Calcolo colore medio locale
color getAverageColor(PImage img, int x, int y, int size) {
  int r = 0, g = 0, b = 0, count = 0;
  for (int i = -size/2; i <= size/2; i++) {
    for (int j = -size/2; j <= size/2; j++) {
      int px = constrain(x+i, 0, img.width-1);
      int py = constrain(y+j, 0, img.height-1);
      color c = img.get(px, py);
      r += int(red(c));
      g += int(green(c));
      b += int(blue(c));
      count++;
    }
  }
  return color(r/count, g/count, b/count);
}

// === PARTICELLA ===
class Particle {
  float x, y;
  float targetX, targetY;
  float angle;
  boolean arrived = false;
  float progress = 0;
  float transitionSpeed;
  int col;

  Particle(float x, float y, int col) {
    this.x = x;
    this.y = y;
    this.targetX = x;
    this.targetY = y;
    this.col = col;
    this.angle = random(TWO_PI);
    this.transitionSpeed = random(0.01, 0.02);
  }

  void setTarget(float newX, float newY, int newCol) {
    this.targetX = newX;
    this.targetY = newY;
    this.col = newCol;
    this.progress = 0;
    this.arrived = false;
  }

  void update() {
    if (!arrived) {
      float dx = targetX - x;
      float dy = targetY - y;
      x += dx * transitionSpeed;
      y += dy * transitionSpeed;
      progress += transitionSpeed;
      if (progress >= 1) {
        x = targetX;
        y = targetY;
        arrived = true;
      }
    } else {
      float amp = 10;
      float freq = 0.1;
      x = targetX + sin(angle) * amp;
      y = targetY + cos(angle) * amp;
      angle += freq;
    }
  }

  void display() {
    noStroke();
    int c = lerpColor(currentImage.get((int)x, (int)y), nextImage.get((int)x, (int)y), transitionProgress);
    fill(c, 150);
    pushMatrix();
    translate(x, y);
    rotate(angle);
    ellipse(0, 0, 20, 35);
    popMatrix();
  }
}
