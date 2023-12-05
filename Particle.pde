class Particle {
  final float INITIAL_LIFESPAN = 255.0;
  final float MASS = random(0.15, 0.3);
  
  PVector position;                         // Current particle position
  PVector lastPosition;                     // Last particle position
  PVector velocity;                         // Initial velocity of the bomb
  PVector acceleration;                     // Acceleration of the bomb
  float lifespan;                           // Lifespan of bomb
  String colour;                            // Particle colour
  
  boolean trails;                           // Trails active
  float speedModifier;                      // Speed Modifier
  float lifetimeModifier;                   // Lifetime Modifier
  float gravityModifier;                    // Gravity Modifier
  float windModifier;                       // Wind Multiplier

  Particle(PVector l, String particleColour, boolean activateTrails, float speedMultiplier, float lifetimeMultiplier, float gravityMultiplier, float windMultiplier, float force) {
    colour = particleColour;
    trails = activateTrails;
    speedModifier = speedMultiplier;
    lifetimeModifier = lifetimeMultiplier;
    gravityModifier = gravityMultiplier;
    windModifier = windMultiplier;
    
    float gravity = 0.2;
    float wind = 0.2;
    acceleration = new PVector(wind * windModifier, gravity * gravityModifier);
    
    float maxVelocity = (force/MASS) * speedModifier;
    velocity = new PVector(random(-maxVelocity, maxVelocity), random(-maxVelocity, maxVelocity), (random(-maxVelocity, maxVelocity)));
    
    position = l.copy();
    lifespan = INITIAL_LIFESPAN * lifetimeModifier;
  }
  
  void setPosition(PVector newPos) {
    position = newPos.copy();
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    lastPosition = position.copy();
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 2.0;
  }

  // Method to display
  void display() {
    switch (colour) {
      case "white": stroke(255, lifespan); break;
      case "blue": stroke(0, 0, 205, lifespan); break;
      case "green": stroke(0, 150, 0, lifespan); break;
      case "red": stroke(255, 0, 0, lifespan); break;
    }
    strokeWeight(4);  
    point(position.x, position.y, position.z);
    if (trails) {
      strokeWeight(1);
      line(position.x, position.y, position.z, lastPosition.x, lastPosition.y, lastPosition.z);
    }
  }

  // Is the particle still useful?
  boolean isDead() {
    return (lifespan < 0.0);
  }
}
