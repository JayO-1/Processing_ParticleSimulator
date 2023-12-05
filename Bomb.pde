interface Bomb {
  void run();
  void update();
  void display();
  void addParticle();
  boolean dead();
  void setPosition(PVector newPos);
}
