//class TCPReceiver
class TCPReceiver {
  ServerSocket server;
  int port;

  TCPReceiver(int port) {
    this.port = port;
    try {
      server = new ServerSocket(port);
      println("🟢 Server TCP avviato sulla porta " + port);
    } catch (IOException e) {
      println("❌ Errore creazione server: " + e);
    }
  }

  PImage checkForImage() {
    try {
      server.setSoTimeout(10); // non blocca draw()
      Socket client = server.accept();

      BufferedReader reader = new BufferedReader(new InputStreamReader(client.getInputStream()));
      StringBuilder b64Builder = new StringBuilder();
      String line;

      while ((line = reader.readLine()) != null) {
        if (line.contains("<END>")) break;
        if (line.contains("<SLEEP>") || line.contains("<ENDSLEEP>")) continue;
        b64Builder.append(line);
      }

      client.close();

      byte[] imageBytes = Base64.getDecoder().decode(b64Builder.toString());
      return saveAndLoadImage(imageBytes);
    } catch (SocketTimeoutException e) {
      // normale: nessuna connessione
    } catch (Exception e) {
      println("⚠️ Errore ricezione immagine: " + e);
    }
    return null;
  }

  PImage saveAndLoadImage(byte[] bytes) {
    try {
      String filename = "received.jpg";
      File file = new File(sketchPath(filename));
      FileOutputStream fos = new FileOutputStream(file);
      fos.write(bytes);
      fos.close();
      return loadImage(filename);
    } catch (Exception e) {
      println("❌ Errore salvataggio/caricamento immagine: " + e);
      return null;
    }
  }
}
