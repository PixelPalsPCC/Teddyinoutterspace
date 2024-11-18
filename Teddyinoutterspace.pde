// Camera variables
float cameraZ = 0;
float targetZ = 0;
float rotationX, rotationY;
float easing = 0.05;
float earthRotation = 0;  // Daily rotation
float earthTilt = radians(23.5);  // Axial tilt
float earthOrbit = 0;  // Annual orbit
float earthSize = 100;  // Diameter of earth display
// Teddy variables
PImage teddy;
float teddyX, teddyY, teddyZ;
PImage earth;

// Star arrays
int[] starX = new int[200];
int[] starY = new int[200];
int[] starZ = new int[200];
color[] starColor = new color[200];
int starSize = 2;
int twinkleTimer = 0;

// Trail variables
int trailLength = 20;
float[] trailX = new float[trailLength];
float[] trailY = new float[trailLength];
float[] trailZ = new float[trailLength];
int trailWidth = 50;

void setup() {
  size(600, 600, P3D);

  // Load and verify teddy image
  teddy = loadImage("teddyinspaceteenynobackground.png");
  earth=loadImage("Earth.png");
 
  if (teddy == null) {
    println("ERROR: Failed to load image!");
    println("Make sure the image file is in the data folder and the name matches exactly");
    exit();
 }
  if (earth == null) {
    println("ERROR: Failed to load earth image!");
    println("Make sure earth.png is in the data folder");
    exit();
  }
  
  // Initialize positions}
  teddyX = width/2;
  teddyY = height/2;
  teddyZ = 0;
  
  initializeTrail();
  initializeStars();
}

void initializeTrail() {
  for (int i = 0; i < trailLength; i++) {
    trailX[i] = teddyX;
    trailY[i] = teddyY;
    trailZ[i] = teddyZ;
  }
}

void initializeStars() {
  for (int i = 0; i < starX.length; i++) {
    starX[i] = (int)random(-width, width*2);
    starY[i] = (int)random(-height, height*2);
    starZ[i] = (int)random(-500, 500);  // Add this line
    starColor[i] = color(255, random(200, 255));
  }
}

void draw() {
  background(0, 0, 50);
  pushMatrix(); 
  updateCamera();
  updateTeddyPosition();
  updateTrail();
  
  // Draw 3D elements
  drawTrail();
  updateAndDrawStars();
  drawTeddy();
  popMatrix();  // Add semicolon here
  
  //Draw 2D overlay elements last
  drawEarth();
}


void updateCamera() {
  // Smooth camera movement
  cameraZ += (targetZ - cameraZ) * easing;  
  translate(width/2, height/2, cameraZ);
  rotateX(rotationX);
  rotateY(rotationY);
}

void updateTeddyPosition() {
  float targetX = mouseX - width/2;
  float targetY = mouseY - height/2;
  teddyX += (targetX - teddyX) * easing;
  teddyY += (targetY - teddyY) * easing;
}

void updateTrail() {
  for (int i = 0; i < trailLength-1; i++) {
    trailX[i] = trailX[i+1];
    trailY[i] = trailY[i+1];
    trailZ[i] = trailZ[i+1];
  }
  trailX[trailLength-1] = teddyX;
  trailY[trailLength-1] = teddyY;
  trailZ[trailLength-1] = teddyZ;
}

void drawTrail() {
  for (int i = 0; i < trailLength-1; i++) {
    float alpha = map(i, 0, trailLength-1, 0, 255);
    float trailSize = map(i, 0, trailLength-1, trailWidth/4, trailWidth);
    
    for (int j = 0; j < 3; j++) {
      float offsetX = random(-trailSize/2, trailSize/2);
      float offsetY = random(-trailSize/2, trailSize/2);
      float offsetZ = random(-trailSize/2, trailSize/2);
      float starSize = random(2, 4);
      
      pushMatrix();
      translate(trailX[i] + offsetX, trailY[i] + offsetY, trailZ[i] + offsetZ);
      fill(255, 255, 255, alpha);
      drawStar(starSize, alpha);
      popMatrix();
    }
  }
}

void updateAndDrawStars() {
  // Update twinkle effect
  if (++twinkleTimer > 10) {
    for (int i = 0; i < 3; i++) {
      int starIndex = (int)random(starX.length);
      starColor[starIndex] = color(255, random(200, 255));
    }
    twinkleTimer = 0;
  }

  // Draw stars
  for (int i = 0; i < starX.length; i++) {
    pushMatrix();
    translate(starX[i] - width/2, starY[i] - height/2, starZ[i]);
    rotateX(frameCount * 0.01);
    rotateY(frameCount * 0.01);
    fill(starColor[i]);
    drawStar(starSize, 255);
    popMatrix();
  }
}


void drawTeddy() {
  if (teddy != null) {
    pushMatrix();
    translate(teddyX, teddyY, teddyZ);
    rotateX(-rotationX);
    rotateY(-rotationY);
    imageMode(CENTER);
    image(teddy, 0, 0);
    popMatrix();
  }
}
void drawEarth() {
  // Save the current transformation matrix
  pushMatrix();
  // Reset all transformations
 resetMatrix();
  // Switch to 2D projection for HUD-style overlay
  hint(DISABLE_DEPTH_TEST);
  camera();
  // Draw the earth image in the bottom right corner
   // Position in bottom right
  translate(width - earthSize/2 - 20, height - earthSize/2 - 20, 0);
  
  // Annual orbit (very slow)
  rotateY(earthOrbit);
  
  // Axial tilt
  rotateZ(earthTilt);
  
  // Daily rotation
  rotateY(earthRotation);
  
  imageMode(CORNER);
  image(earth,0,0,earthSize,earthSize);
  // Update rotations
  earthRotation += 0.01;  // Daily rotation (adjust for desired speed)
  earthOrbit += 0.0001;   // Annual orbit (much slower)
  
  hint(ENABLE_DEPTH_TEST);
  // Restore the transformation matrix
  popMatrix();
}


void drawStar(float size, float brightness) {
  stroke(255, 255, 255, brightness);
  strokeWeight(1);
  float innerSize = size * 0.4;
  
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i <= 10; i++) {
    float angle = i * TWO_PI / 5;
    float r = (i % 2 == 0) ? size : innerSize;
    float x = cos(angle) * r;
    float y = sin(angle) * r;
    vertex(x, y, 0);
  }
  endShape(CLOSE);
}

void mouseDragged() {
  rotationY = constrain(rotationY + (mouseX - pmouseX) * 0.01, -PI, PI);
  rotationX = constrain(rotationX + (mouseY - pmouseY) * 0.01, -PI/2, PI/2);
}


void mouseWheel(MouseEvent event) {
  targetZ += event.getCount() * 50;
}
