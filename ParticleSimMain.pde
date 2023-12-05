import java.util.*;
import peasy.*;
import controlP5.*;

PeasyCam cam;
PMatrix3D currCameraMatrix;
PGraphics3D g3;
ControlP5 cp5;

// Default values
final int INITIAL_NUM_BOMB_PARTICLES = 100;
final int INITIAL_NUM_SCATTER_PARTICLES = 5;
final String INITIAL_PARTICLE_COLOUR = "white";
final boolean INITIAL_TRAILS = false;
final float INITIAL_SPEED_MULTIPLIER = 1;
final float INITIAL_LIFETIME_MULTIPLIER = 1;
final float INITIAL_GRAVITY_MULTIPLIER = 1;
final float INITIAL_WIND_MULTIPLIER = 0;

// Working variables
int numBombParticles = INITIAL_NUM_BOMB_PARTICLES;
int numScatterBombParticles = INITIAL_NUM_SCATTER_PARTICLES;
String particleColour = INITIAL_PARTICLE_COLOUR;
boolean activateTrails = INITIAL_TRAILS;
float speedMultiplier = INITIAL_SPEED_MULTIPLIER;
float lifetimeMultiplier = INITIAL_LIFETIME_MULTIPLIER;
float gravityMultiplier = INITIAL_GRAVITY_MULTIPLIER;
float windMultiplier = INITIAL_WIND_MULTIPLIER;

float floorX, floorY, floorSurfaceY;
ArrayList<Bomb> bombSystems;

void setup() {
  size(1000, 1000, P3D);
  
  floorX = width/2;
  floorY = height - 100;
  floorSurfaceY = floorY - 105;
  bombSystems = new ArrayList<Bomb>();
  
  cam = new PeasyCam(this, width/2, height/2, 0, 1000);
  g3 = (PGraphics3D) g;
  
  // Construct UI
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  
  // Variables for controlling button layout
  int buttonWidth = 100;
  int buttonHeight = 50;
  int buttonX = width/4;
  int buttonY = height/8;
  int buttonSpacingX = buttonWidth + 10;
  int buttonSpacingY = buttonHeight + 10;
  
  // Button content
  String[][] buttons = {
    {
      "increaseParticles",
      "decreaseParticles"
    }
  };
  
  // Placing buttons in grid
  String buttonName;
  for (int row = 0; row < buttons.length; row++) {
    for (int col = 0; col < buttons[row].length; col++) {
      buttonName = buttons[row][col];
      
      cp5.addButton(buttonName)
      .setValue(0)
      .setPosition(buttonX + (row * buttonSpacingX), buttonY + (col * buttonSpacingY))
      .setSize(buttonWidth, buttonHeight);
    }
  }
 
  // Variables for dropdown colour layout
  List colourOptions = Arrays.asList("white", "blue", "green", "red");
  int dropdownWidth = 100;
  int dropdownHeight = 100;
  int dropdownX = buttonX;
  int dropdownY = buttonY - 50;
  
  // add a ScrollableList, by default it behaves like a DropdownList
  cp5.addScrollableList("colours")
     .setPosition(dropdownX, dropdownY)
     .setSize(dropdownWidth, dropdownHeight)
     .setBarHeight(30)
     .setItemHeight(20)
     .addItems(colourOptions);
  
  // Variables for slider layout
  int sliderWidth = 20;
  int sliderHeight = buttonWidth;
  int sliderX = buttonX + buttonWidth + sliderWidth;
  int sliderY = buttonY;
  int sliderSpacing = sliderWidth * 4;
  
  // Sliders for multipliers
  String[] sliders = {
    "speedMultiplier",
    "lifetimeMultiplier",
    "gravityMultiplier",
    "windMultiplier"
  };
  
  String slider;
  int startOfRange = 1, endOfRange = 4;
  for (int sliderIndex = 0; sliderIndex < sliders.length; sliderIndex++) {
    slider = sliders[sliderIndex];
    
    if (slider.equals("gravityMultiplier") || slider.equals("windMultiplier")) {
      startOfRange = 0;
    }
    
    cp5.addSlider(slider)
     .setPosition(sliderX + (sliderSpacing * sliderIndex), sliderY)
     .setSize(sliderWidth,sliderHeight)
     .setRange(startOfRange,endOfRange)
     .setDecimalPrecision(0);
  }
  
  // Variables for toggles
  int toggleWidth = 50;
  int toggleHeight = 20;
  int toggleX = dropdownX + (toggleWidth * 2) + 10;
  int toggleY = dropdownY;
  
  // Toggles
  cp5.addToggle("activateTrails")
     .setPosition(toggleX,toggleY)
     .setSize(toggleWidth,toggleHeight)
     .setValue(false)
     .setMode(ControlP5.SWITCH);
}

void draw() {
  background(0);
  lights();

  // Creating platform
  pushMatrix();
  translate(floorX, floorY, 0);
  noStroke();
  fill(60);
  box(900, 200, 800);
  popMatrix();
  
  for (Bomb ps : bombSystems) {
    ps.run();
  }
  
  // If no bombs in play, display initial screen
  if (bombSystems.isEmpty()) {
    //cp5.setVisible(false);
    
    textAlign(CENTER);
    int textSize = 20;
    
    String[] texts = { 
                       "press space to add bomb",
                       "press s to add scatter bomb",
                       "r: reset"
                     };
                     
    displayText(texts, textSize);
  } else {
    //cp5.setVisible(true);
    gui();
    displayCurrentAttributes();
  }
}

public void increaseParticles(int theValue) {
  numBombParticles += 100;
  numScatterBombParticles += 5;
}

public void decreaseParticles(int theValue) {
  if (numBombParticles > 0) {
    numBombParticles -= 100;
    numScatterBombParticles -= 5;
  }
}

public void colours(int n) {
  String newColour = (String) cp5.get(ScrollableList.class, "colours").getItem(n).get("name");
  particleColour = newColour;
}

void gui() {
  currCameraMatrix = new PMatrix3D(g3.camera);
  camera();
  cp5.draw();
  g3.camera = currCameraMatrix;
}

void displayText(String[] texts, int textSize) {
  fill(255);
  textSize(textSize);
  
  String text;
  for (int i = 0; i < texts.length; i++) {
      text = texts[i];
      text(text, width/2, height/2 + ((textSize * i) + textSize));
  }
}

void displayCurrentAttributes() {
  fill(255);
  
  int textSize = 17;
  textSize(textSize);
  
  String[] texts = { 
                    "fps: " + Math.floor(frameRate),
                    "particles per bomb: " + numBombParticles,
                    "bombs per scatter bomb: " + numScatterBombParticles,
                   };
  
  String text;
  for (int i = 0; i < texts.length; i++) {
      text = texts[i];
      text(text, width/2 + 20, height/15 + ((textSize * i) + textSize));
  }
}

void keyPressed() {
  if (key == ' ') {
    bombSystems.add(new BombParticleSystem(numBombParticles, new PVector(mouseX, mouseY), new PVector(floorX, floorSurfaceY), particleColour, activateTrails, speedMultiplier, lifetimeMultiplier, gravityMultiplier, windMultiplier));
  } else if (key == 's') {
    bombSystems.add(new ScatterBombParticleSystem(numScatterBombParticles, numBombParticles, new PVector(mouseX, mouseY), new PVector(floorX, floorSurfaceY), particleColour, activateTrails, speedMultiplier, lifetimeMultiplier, gravityMultiplier, windMultiplier));
  } else if (key == 'r') {
    // Resetting world state
    cam.reset();
    bombSystems.clear();
    
    // Resetting atrributes
    numBombParticles = INITIAL_NUM_BOMB_PARTICLES;
    numScatterBombParticles = INITIAL_NUM_SCATTER_PARTICLES;

    speedMultiplier = INITIAL_SPEED_MULTIPLIER;

    particleColour = INITIAL_PARTICLE_COLOUR;

    lifetimeMultiplier = INITIAL_LIFETIME_MULTIPLIER;

    gravityMultiplier = INITIAL_GRAVITY_MULTIPLIER;
    windMultiplier = INITIAL_WIND_MULTIPLIER;
    
    // Resetting p5 controllers
    String[] controllers = {
      "speedMultiplier",
      "lifetimeMultiplier",
      "gravityMultiplier",
      "windMultiplier"
    };
    
    for (String controller : controllers) {
      switch(controller) {
        case "speedMultiplier": cp5.getController(controller).setValue(INITIAL_SPEED_MULTIPLIER); break;
        case "lifetimeMultiplier": cp5.getController(controller).setValue(INITIAL_LIFETIME_MULTIPLIER); break;
        case "gravityMultiplier": cp5.getController(controller).setValue(INITIAL_GRAVITY_MULTIPLIER); break;
        case "windMultiplier": cp5.getController(controller).setValue(INITIAL_WIND_MULTIPLIER); break;
      }
    }
  }
}
