class BombParticleSystem implements Bomb {
  final float INITIAL_VELOCITY = 5.0;
  final float INITIAL_LIFESPAN = 255.0;
  final float INITIAL_FORCE = 17.0;

  ArrayList<Particle> particles;    // An arraylist for all the particles

  PVector position;                         // Current bomb position
  PVector floor;                            // Location of floor
  PVector velocity;                         // Initial velocity of the bomb
  PVector acceleration;                     // Acceleration of the bomb
  float lifespan;                           // Lifespan of bomb
  String subParticleColour;                 // Particle colour
  
  boolean trails;                           // Trails active
  float speedModifier;                      // Speed Modifier
  float lifetimeModifier;                   // Lifetime Modifier
  float gravityModifier;                    // Gravity Modifier
  float windModifier;                       // Wind Multiplier

  BombParticleSystem(int num, PVector v, PVector ground, String particleColour, boolean activateTrails, float speedMultiplier, float lifetimeMultiplier, float gravityMultiplier, float windMultiplier) {
    particles = new ArrayList<Particle>();   // Initialize the arraylist
    position = v.copy();
    
    subParticleColour = particleColour;               
    trails = activateTrails;
    speedModifier = speedMultiplier;
    lifetimeModifier = lifetimeMultiplier;
    gravityModifier = gravityMultiplier;
    windModifier = windMultiplier;
    
    for (int i = 0; i < num; i++) {
      addParticle();   // Add "num" amount of particles to the arraylist
    }

    // Next, initialise the parameters of the bomb
    floor = ground.copy();
    
    float gravity = 0.2;
    float wind = 0.01;
    acceleration = new PVector(wind * windModifier, gravity * gravityModifier);
    
    velocity = new PVector(0, 0);
    
    lifespan = INITIAL_LIFESPAN * lifetimeModifier;
  }

  BombParticleSystem(int num, PVector v, PVector ground,  String particleColour, boolean activateTrails, float speedMultiplier, float lifetimeMultiplier, float gravityMultiplier, float windMultiplier, float lifespan) {
    particles = new ArrayList<Particle>();   // Initialize the arraylist
    position = v.copy();
   
    subParticleColour = particleColour;            
    trails = activateTrails;
    speedModifier = speedMultiplier;
    lifetimeModifier = lifetimeMultiplier;
    gravityModifier = gravityMultiplier;
    windModifier = windMultiplier;
    
    for (int i = 0; i < num; i++) {
      addParticle();   // Add "num" amount of particles to the arraylist
    }

    // Next, initialise the parameters of the bomb
    floor = ground.copy();
    
    float gravity = 0.2;
    float wind = 0.03;
    acceleration = new PVector(wind * windModifier, gravity * gravityModifier);
    
    float maxVelocity = INITIAL_VELOCITY * speedModifier;
    velocity = new PVector(random(-maxVelocity, maxVelocity), random(-maxVelocity, 0), (random(-maxVelocity, maxVelocity)));
    
    this.lifespan = lifespan * lifetimeModifier;
  }

  void run() {
    // Indicates it wasn't set, meaning we should treat as a normal bomb
    if (lifespan == Integer.MIN_VALUE) {
      if (position.y < floor.y) {
        update();
        display();
      } else {
        // Cycle through the ArrayList backwards, because we are deleting while iterating
        for (int i = particles.size()-1; i >= 0; i--) {
          Particle p = particles.get(i);
          p.run();
          if (p.isDead()) {
            particles.remove(i);
          }
        }
      }
    }
    // Otherwise, we must treat as a scatter bomb, and so check if it has hit
    // the floor OR lifespan has been exceeded
    else {
      if (position.y < floor.y && !isDead()) {
         update();
         display();
      } else {
        // Cycle through the ArrayList backwards, because we are deleting while iterating
        for (int i = particles.size()-1; i >= 0; i--) {
          Particle p = particles.get(i);
          p.run();
          if (p.isDead()) {
            particles.remove(i);
          }
        }
      }
    }
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 2.0;
    
    if (isDead() || position.y >= floor.y) {
      // Update position of particles
      for (int i = particles.size()-1; i >= 0; i--) {
        Particle p = particles.get(i);
        p.setPosition(position);
      }
    }
  }

  // Method to display
  void display() {
    stroke(80);
    strokeWeight(10);
    point(position.x, position.y);
    strokeWeight(2);
  }

  void addParticle() {
    Particle p = new Particle(position, subParticleColour, trails, speedModifier, lifetimeMultiplier, gravityMultiplier, windMultiplier, INITIAL_FORCE);
    particles.add(p);
  }

  void addParticle(Particle p) {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    return particles.isEmpty();
  }
  
  // Is the particle still useful?
  boolean isDead() {
    return (lifespan < 0.0);
  }
  
  void setPosition(PVector newPos) {
    position = newPos.copy();
    
    // Update position of particles
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.setPosition(position);
    }
  }
}
