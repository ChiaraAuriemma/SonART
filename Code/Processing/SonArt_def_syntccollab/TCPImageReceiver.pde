class TCPImageReceiver {
  ServerSocket server;
  ArrayList<ScheduledImage> queue;
  int startTime = -1;

  TCPImageReceiver(int port) {
    queue = new ArrayList<ScheduledImage>();
    try {
      server = new ServerSocket(port);
      server.setSoTimeout(10);
      println("🟢 Server TCP in ascolto sulla porta " + port);
    } catch (IOException e) {
      println("❌ Errore apertura porta: " + e.getMessage());
    }
  }

  void checkForNewImage() {
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

          if (startTime < 0) {
            startTime = millis();
            println("⏱️ Timer avviato a " + startTime);
          }
        }
      }

      reader.close();
      client.close();
    } catch (SocketTimeoutException e) {
      // Nessuna connessione, normale
    } catch (IOException e) {
      println("⚠️ Errore ricezione immagine: " + e.getMessage());
    }
  }

  ScheduledImage getNextImageIfReady() {
    if (startTime >= 0 && queue.size() > 0) {
      int elapsed = millis() - startTime;
      ScheduledImage next = queue.get(0);
      if (elapsed >= next.timestamp) {
        queue.remove(0);
        return next;
      }
    }
    return null;
  }
}
