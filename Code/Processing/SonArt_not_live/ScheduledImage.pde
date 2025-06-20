class ScheduledImage {
  int timestamp;
  PImage img;
  color[][] precomputedColors;  // <-- Aggiungi questa riga!

  ScheduledImage(int t, PImage i) {
    timestamp = t;
    img = i;
  }
}
