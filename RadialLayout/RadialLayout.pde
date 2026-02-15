/**
 * Bake Off 1: Phase 2
 * Authors: Loic Kraemer Bastos, Zhengyao Li, and Aidan Sheehan
 * Date: 2026-02-11
 * CS3540
 * 
 * Radial Layout prototype
 */

import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;

int margin = 200; // set the margin around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); // contains the order of buttons that activate in the test
int trialNum = 0; // the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; // records the time of the final click
int hits = 0; // number of successful clicks
int misses = 0; // number of missed clicks
Robot robot; // initialized in setup

int numRepeats = 1; // sets the number of times each button repeats in the test

// Radial Layout
boolean radialMode = false; // flag to use the radial layout. False uses the original 4x4 layout
final int numButtons = 16;
final float offset = PI / numButtons;
int radius = width / 2;
int innerRadius = radius / 4;
float translateX = radius;
float translateY = radius;

void settings() {
  size(700, 700);
}

void setup() {
  // noCursor(); // hides the system cursor if you want
  noStroke(); // turn off all strokes, we're just using fills here
  textFont(createFont("Arial", 16)); // sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60); // normally you can't go much higher than 60 FPS.
  ellipseMode(CENTER); // ellipses are drawn from the center

  try {
    robot = new Robot(); // create a Java Robot class that can move the system cursor
  } catch (AWTException e) {
    e.printStackTrace();
  }

  // ===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++)
    for (int k = 0; k < numRepeats; k++)
      trials.add(i);

  Collections.shuffle(trials);
  println("trial order: " + trials);

  surface.setLocation(0, 0);

  radius = width / 2;
  innerRadius = radius / 4;
  translateX = radius;
  translateY = radius;
}

void draw() {
  background(0);

  if (trialNum >= trials.size()) {
    drawEndScreen();
    return;
  }

  fill(255);
  text((trialNum + 1) + " of " + trials.size(), 40, 20);

  for (int i = 0; i < 16; i++)
    drawButton(i);

  fill(255, 0, 0, 200);
  ellipse(mouseX, mouseY, 20, 20);
}

void mousePressed() {
  if (trialNum >= trials.size())
    return;

  if (trialNum == 0)
    startTime = millis();

  if (trialNum == trials.size() - 1) 
    finishTime = millis();
  

  int targetID = trials.get(trialNum);
  int selectedButtonID = testButtonCollision(mouseX, mouseY);
  if(selectedButtonID == targetID){
    System.out.println("HIT! Trial:" + trialNum + ". Target: "+targetID+". Cumulative time:" + (millis() - startTime)); // success
    hits++;
  } else {
    System.out.println("MISSED! Trial:" + trialNum + ". Selected "+selectedButtonID+" but target was "+targetID+". Cumulative time:" + (millis() - startTime)); // fail
    misses++;
  }

  trialNum++;
}

// Rectangle getButtonLocation(int i) {
//   int x = (i % 4) * (padding + buttonSize) + margin;
//   int y = (i / 4) * (padding + buttonSize) + margin;
//   return new Rectangle(x, y, buttonSize, buttonSize);
// }

PShape getButtonBounds(int i) {
  PShape button = createShape();
  button.beginShape(QUADS);
  if (radialMode) {
    int x1, y1, x2, y2, x3, y3, x4, y4;

    // Vertex positions
    // p1 p2
    // p4 p3
    x1 = int(cos((TWO_PI / numButtons) * i + HALF_PI + offset) * radius + translateX);
    y1 = int(sin((TWO_PI / numButtons) * i + HALF_PI + offset) * radius + translateY);
    x2 = int(cos((TWO_PI / numButtons) * i + HALF_PI - offset) * radius + translateX);
    y2 = int(sin((TWO_PI / numButtons) * i + HALF_PI - offset) * radius + translateY);
    x3 = int(cos((TWO_PI / numButtons) * i + HALF_PI - offset) * innerRadius + translateX);
    y3 = int(sin((TWO_PI / numButtons) * i + HALF_PI - offset) * innerRadius + translateY);
    x4 = int(cos((TWO_PI / numButtons) * i + HALF_PI + offset) * innerRadius + translateX);
    y4 = int(sin((TWO_PI / numButtons) * i + HALF_PI + offset) * innerRadius + translateY);

    // println("Button " + i + ": ("+x1+" "+y1+") ("+x2+" "+y2+") ("+x3+" "+y3+") ("+x4+" "+y4+")");

    button.vertex(x1, y1);
    button.vertex(x2, y2);
    button.vertex(x3, y3);
    button.vertex(x4, y4);
  }
  else {
    int x = (i % 4) * (padding + buttonSize) + margin;
    int y = (i / 4) * (padding + buttonSize) + margin;
    
    // Equivalent to: createShape(RECT, x, y, buttonSize, buttonSize);
    button.vertex(x, y);
    button.vertex(x + buttonSize, y);
    button.vertex(x + buttonSize, y + buttonSize);
    button.vertex(x, y + buttonSize);
  }
  button.endShape();
  return button;
}

int testButtonCollision(int locX, int locY) {
  if (radialMode) {
    // mouse click is valid if the distance of the position from the center is <= the circle's radius
    float centerX = width / 2;
    float centerY = height / 2;

    float deltaX = centerX - locX;
    float deltaY = centerY - locY;

    float distance = sqrt(sq(deltaX) + sq(deltaY));
    if (distance > radius || distance < innerRadius) {
      print("No Circle Collision: " + distance + " > " + radius);
      return -1;
    }

    float offset = PI / numButtons;

    for (int i = 0; i < numButtons; i++) {
      // p1 p2
      // p4 p3
            
      // Centered around 0,0
      float x1 = (cos((TWO_PI / numButtons) * i + HALF_PI + offset));// * radius);
      float y1 = (sin((TWO_PI / numButtons) * i + HALF_PI + offset));// * radius);
      float x2 = (cos((TWO_PI / numButtons) * i + HALF_PI - offset));// * radius);
      float y2 = (sin((TWO_PI / numButtons) * i + HALF_PI - offset));// * radius);

      PVector start = new PVector(x1, y1);
      PVector end = new PVector(x2, y2);
      start.normalize();
      end.normalize();
      PVector loc = new PVector(locX - translateX, -(locY - translateY));
      loc.normalize();

      // println("Button "+i+": " + loc.x + ", " + loc.y + " (" + start.x + ", " + start.y + ") (" + end.x + ", " + end.y + ")");
      // println(loc.x + " " + loc.y + " (" + x1 + " " + y1 + ") (" + x2 + " " + y2 + ")");
      println("Angle between "+i+" ("+degrees(2 * offset)+"): " + degrees(PVector.angleBetween(start, loc)) + " " + degrees(PVector.angleBetween(end, loc)));

      // Inside a sector: 1. loc point is inside radius 
      // 2. AND loc point is within a button angle of start arm 
      // 3. AND loc point is within a button angle of end arm
      boolean isWithinStart = PVector.angleBetween(start, loc) < (2 * offset);
      boolean isWithinEnd = PVector.angleBetween(end, loc) < (2 * offset);
      if (isWithinStart && isWithinEnd)
        return i;
      
    }
  }
  else {
    for (int i = 0; i < numButtons; i++) {
      PShape button = getButtonBounds(i);
      PVector p1 = button.getVertex(0);
      // println(locX + " " + locY + " (" + p1.x + " " + p1.y + " " + button.getWidth() + " " + button.getHeight() + ")");
      if ((locX > p1.x && locX < button.getWidth()) && (locY > p1.y && locY < button.getHeight()))
			  return i;
    }
  }


  return -1;
}

// PShape createRadialButtons() {
//   PShape button = createShape(QUAD);

//   button.beginShape(QUADS);

//   // button.vertex(0, 0); // center
//   for(int i = 0; i <= numButtons; i++) {

//   // Vertex position
//     float x = cos((TWO_PI / numButtons) * i);
//     float y = sin((TWO_PI / numButtons) * i);

//     button.vertex(x, y);
//   }
//   button.endShape();
//   return button;
// }


void drawButton(int i) {
  fill(200);

  if (trials.get(trialNum) == i) // Strictly for changing target's color. Do not modify
    fill(0, 255, 255);

  PShape button = getButtonBounds(i);
  shape(button);
}

void drawEndScreen() {
  float timeTaken = (finishTime - startTime) / 1000f;
  float penalty = constrain(((95f - ((float) hits * 100f / (float) (hits + misses))) * .2f), 0, 100);
  fill(255);
  text("Finished!", width / 2, height / 2);
  text("Hits: " + hits, width / 2, height / 2 + 20);
  text("Misses: " + misses, width / 2, height / 2 + 40);
  text("Accuracy: " + (float) hits * 100f / (float) (hits + misses) + "%", width / 2, height / 2 + 60);
  text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
  text("Average time for each button: " + nf((timeTaken) / (float) (hits + misses), 0, 3) + " sec",
        width / 2, height / 2 + 100);
  text("Average time for each button + penalty: "
        + nf(((timeTaken) / (float) (hits + misses) + penalty), 0, 3) + " sec",
        width / 2, height / 2 + 140);
}

void mouseMoved() {}
void mouseDragged() {}
void keyPressed() {
  if (key == 'c')
    radialMode = !radialMode;
}
