class ScatterBombParticleSystem implements Bomb {
  final float INITIAL_LIFESPAN = 255.0;

  ArrayList<Bomb> particles;    // An arraylist for all the particles

  PVector position;                         // Current bomb position
  PVector floor;                            // Location of floor
  PVector velocity;                         // Initial velocity of the bomb
  PVector acceleration;                     // Acceleration of the bomb
  int subBombParticleCount;                 // Number of particles per sub bomb
  float lifespan;                           // ScatterBomb lifespan
  float subBombLifespan = 128.0;            // Lifespan of a given sub bomb
  String colour;                            // Particle colour
  
  boolean trails;                           // Trails active
  float speedModifier;                      // Speed Modifier
  float lifetimeModifier;                   // Lifetime Modifier
  float gravityModifier;                    // Gravity Modifier
  float windModifier;                       // Wind Modifier

  ScatterBombParticleSystem(int numSubBombs, int particlesPerSubBomb, PVector v, PVector ground, String particleColour, boolean activateTrails, float speedMultiplier, float lifetimeMultiplier, float gravityMultiplier, float windMultiplier) {
    particles = new ArrayList<Bomb>();           // Initialize the arraylist
    position = v.copy();
    
    floor = ground.copy();                       // Establish a ground
    subBombParticleCount = particlesPerSubBomb;  // Particles per sub bomb
    
    colour = particleColour;         
    trails = activateTrails;
    speedModifier = speedMultiplier;
    lifetimeModifier = lifetimeMultiplier;
    gravityModifier = gravityMultiplier;
    windModifier = windMultiplier;
    for (int i = 0; i < numSubBombs; i++) {
      addParticle();   // Add "num" amount of particles to the arraylist
    }

    // Next, initialise the parameters of the bomb
    float gravity = 0.2;
    float wind = 0.01;
    acceleration = new PVector(wind * windModifier, gravity * gravityModifier);
    
    velocity = new PVector(0, 0);
    sphereDetail(3);
    
    lifespan = INITIAL_LIFESPAN * lifetimeModifier;
  }

  void run() {
    if (position.y < floor.y && !isDead()) {
      update();
      display();
    } else {
      // Cycle through the ArrayList backwards, because we are deleting while iterating
      for (int i = particles.size()-1; i >= 0; i--) {
        Bomb b = particles.get(i);
        b.run();
        if (b.dead()) {
          particles.remove(i);
        }
      }
    }
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 2.0;

    if (position.y >= floor.y) {
      // Update position of particles
      for (int i = particles.size()-1; i >= 0; i--) {
        Bomb b = particles.get(i);
      
        PVector positionSlightlyAbove = position.copy();
        positionSlightlyAbove.y -= 10;
        b.setPosition(positionSlightlyAbove);
      }
    }
  }

  // Method to display
  void display() {
    pushMatrix();
    noStroke();
    fill(0, 179, 0);
    translate(position.x, position.y);
    sphere(10);
    popMatrix();
  }

  void addParticle() {
    Bomb b = new BombParticleSystem(subBombParticleCount, position, floor, colour, trails, speedModifier, lifetimeModifier, gravityModifier, windModifier, subBombLifespan);
    particles.add(b);
  }

  void addParticle(Bomb b) {
    particles.add(b);
  }
  
  // Is the particle still useful?
  boolean isDead() {
    return (lifespan < 0.0);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    return particles.isEmpty();
  }
  
  void setPosition(PVector newPos) {
    position = newPos.copy();
  }
}
