class ScheduledImage {
  int timestamp;
  PImage img;
  color[][] precomputedColors; 

  ScheduledImage(int t, PImage i) {
    timestamp = t;
    img = i;
  }
}
