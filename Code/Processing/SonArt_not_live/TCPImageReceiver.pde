
class TCPImageReceiver {
  ServerSocket server;
  final List<ScheduledImage> queue;

  TCPImageReceiver(int port) {
    queue = Collections.synchronizedList(new ArrayList<>());
    try {
      server = new ServerSocket(port);
      println("Server TCP in ascolto sulla porta " + port);
    } catch (IOException e) {
      println("Errore apertura porta: " + e.getMessage());
    }
  }

  ScheduledImage nextImageBlocking() {
    while (true) {
      synchronized(queue) {
        if (!queue.isEmpty()) {
          return queue.remove(0);
        }
      }
      try {
        server.setSoTimeout(0);
        acceptAndRead();
      } catch (IOException e) {
        println("Errore ricezione immagine: " + e.getMessage());
      }
    }
  }

  private void acceptAndRead() throws IOException {
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
        received.resize(1200, 800);

        synchronized(queue) {
          queue.add(new ScheduledImage(timestamp, received));
        }
        println("📥 Ricevuta immagine per t=" + timestamp + " ms");
      }
    }
    client.close();
  }
}
