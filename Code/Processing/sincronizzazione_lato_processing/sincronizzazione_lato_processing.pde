import java.net.*;
import java.io.*;
import java.util.*;
import java.awt.image.BufferedImage;
import java.util.Base64;
import javax.imageio.ImageIO;


ArrayList<ScheduledImage> queue = new ArrayList<ScheduledImage>(); //lista di immagini ricevute 
int sketchStartTime = -1; // Momento in cui inizia il tempo di riferimento
PImage currentImage = null;
int port = 12345;
ServerSocket server;

void setup() {
  size(1400, 800);
  frameRate(60);
  background(255);

  try {
    server = new ServerSocket(port);
    server.setSoTimeout(10);  // timeout breve per non bloccare draw()
    println("🟢 Server TCP in ascolto sulla porta " + port);
  } catch (IOException e) {
    println("❌ Errore apertura porta: " + e.getMessage());
    exit();
  }
}

void draw() {
  background(255);

  // Ricezione immagine (una connessione per immagine)
  try {
    Socket client = server.accept();
    BufferedReader reader = new BufferedReader(new InputStreamReader(client.getInputStream()));
    String timestampLine = reader.readLine();
    String base64Line = reader.readLine();

    if (timestampLine != null && base64Line != null) {
      int timestamp = Integer.parseInt(timestampLine.trim());
      byte[] imageBytes = Base64.getDecoder().decode(base64Line);
      ByteArrayInputStream bais = new ByteArrayInputStream(imageBytes);
      BufferedImage bimg = ImageIO.read(bais);

      if (bimg != null) {
        PImage received = new PImage(bimg.getWidth(), bimg.getHeight());
        received.loadPixels();
        bimg.getRGB(0, 0, bimg.getWidth(), bimg.getHeight(), received.pixels, 0, bimg.getWidth());
        received.updatePixels();
        received.resize(width, height);

        queue.add(new ScheduledImage(timestamp, received));
        println("📥 Ricevuta immagine per t=" + timestamp + "ms");

        // Avvia il timer allo 0° arrivo
        if (sketchStartTime < 0) {
          sketchStartTime = millis();
          println("⏱️ Timer avviato a " + sketchStartTime);
        }
      }
    }

    reader.close();
    client.close();
  } catch (SocketTimeoutException e) {
    // Nessuna connessione: va bene
  } catch (IOException e) {
    println("⚠️ Errore ricezione immagine: " + e.getMessage());
  }

  // Visualizza immagine al momento giusto
  if (sketchStartTime >= 0 && queue.size() > 0) {
    int elapsed = millis() - sketchStartTime;
    ScheduledImage next = queue.get(0);

    if (elapsed >= next.timestamp) {
      currentImage = next.img;
      queue.remove(0);
      println("🖼️ Mostrata immagine a " + elapsed + "ms");
    }
  }

  // Disegna immagine corrente
  if (currentImage != null) {
    image(currentImage, 0, 0);
  }
}

class ScheduledImage {
  int timestamp;
  PImage img;

  ScheduledImage(int timestamp, PImage img) {
    this.timestamp = timestamp;
    this.img = img;
  }
}
