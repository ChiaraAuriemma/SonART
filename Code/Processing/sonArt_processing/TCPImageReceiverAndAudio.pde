class TCPImageReceiverAndAudio {
  ServerSocket server;
  final List<ScheduledImage> queue;
  String savedAudioPath = "";
  
  Minim minim;
  Clip clip = null; // clip per wav
  volatile AudioPlayer player;
 
  int extention; // 0 mp3, 1 wav

  //starts the TCP server on the given port
  TCPImageReceiverAndAudio(int port, Minim minimInstance) {
    queue = Collections.synchronizedList(new ArrayList<>());
    minim = minimInstance;

    try {
      server = new ServerSocket(port);
      println("TCP server listening on port " + port);
    } catch (IOException e) {
      println("Error opening port: " + e.getMessage());
      return;
    }

    //Thread to continuously accept new client connections
    new Thread(() -> {
      while (!server.isClosed()) {
        try {
          Socket client = server.accept();
          println("New connection from " + client.getInetAddress());

          //For each connection, spawn a new thread to handle it
          new Thread(() -> {
            try {
              handleClient(client);
            } catch (Exception e) {
              println("Error handling client: " + e.getMessage());
            }
          }).start();

        } catch (IOException e) {
          println("Error accepting connection: "  + e.getMessage());
          break;
        }
      }
    }).start();
  }

  //Waits until an image is available in the synchronized queue, then removes and returns it.
  ScheduledImage nextImageBlocking() {
    while (true) {
      synchronized(queue) {
        if (!queue.isEmpty()) {
          return queue.remove(0);
        }
      }
      try {
        Thread.sleep(50); // aspetta un po’ prima di ricontrollare
      } catch (InterruptedException e) {
        // Ignora interruzioni
      }
    }
  }
  

  // Handles incoming data from the connected client
  private void handleClient(Socket client) throws IOException {
    BufferedReader reader = new BufferedReader(new InputStreamReader(client.getInputStream(), "UTF-8"));
    String dataType;

    while ((dataType = reader.readLine()) != null) {
      if (dataType.equals("AUDIO")) {
        // Read audio data until EOF marker is reached
        StringBuilder audioBuilder = new StringBuilder();
        String line;
        String EOF_MARKER = "<<EOF>>";

        while ((line = reader.readLine()) != null) {
          if (line.contains(EOF_MARKER)) {
            audioBuilder.append(line.replace(EOF_MARKER, ""));
            break;
          }
          audioBuilder.append(line);
        }

        String base64Audio = audioBuilder.toString();
        println("Received base64 audio, length: " + base64Audio.length());

        // Decode and save audio to file
        byte[] audioBytes = Base64.getDecoder().decode(base64Audio);

        String fileExtension = determineAudioFormat(audioBytes);
        savedAudioPath = sketchPath("received." + fileExtension);

        try (FileOutputStream fos = new FileOutputStream(savedAudioPath)) {
          fos.write(audioBytes);
        }

        println("Audio saved (" + fileExtension + "): " + savedAudioPath);
        
        if (player != null && player.isPlaying()) {
          player.close();
        }
        
        if (clip != null && clip.isRunning()) {
          clip.stop();
          clip.close();
        }
        
        // Load the new audio based on its format
        if (fileExtension.equals("mp3")) {
        player = minim.loadFile(savedAudioPath);
       
          } else if (fileExtension.equals("wav")) {
            // Receive and decode timestamp and image
            try {
                File audioFile = new File(savedAudioPath);
                AudioInputStream audioStream = AudioSystem.getAudioInputStream(audioFile);
                AudioFormat format = audioStream.getFormat();
                DataLine.Info info = new DataLine.Info(Clip.class, format);
                clip = (Clip) AudioSystem.getLine(info);
                clip.open(audioStream);
            } catch (UnsupportedAudioFileException | LineUnavailableException e) {
                e.printStackTrace();
                println("Error loading WAV file: " + e.getMessage());
            }
        }
      
        
        
        // Play lo gestisci fuori

      } else if (dataType.equals("IMAGE")) {
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
            println("Received image for t=" + timestamp + " ms");
          }
        }
      } else {
        println("Unknown data type: " + dataType);
        break;
      }
    }

    println("Client connection closed.");
    client.close();
  }
  

  // Determines audio file format based on byte header
  private String determineAudioFormat(byte[] audioData) {
    if (audioData.length < 12) return "mp3"; // default

    //MP3 detection: ID3 header or frame sync
    if ((audioData[0] == 'I' && audioData[1] == 'D' && audioData[2] == '3') ||
        ((audioData[0] & 0xFF) == 0xFF && (audioData[1] & 0xE0) == 0xE0)) {
      extention = 0; 
      return "mp3";
    }
    //WAV detection: RIFF + WAVE
    if (audioData[0] == 'R' && audioData[1] == 'I' && audioData[2] == 'F' && audioData[3] == 'F' &&
        audioData[8] == 'W' && audioData[9] == 'A' && audioData[10] == 'V' && audioData[11] == 'E') {
      extention =1; 
      return "wav";
    }
    return "mp3"; // default
  }
}
