/**
 * Bake Off 1: Phase 3
 * Authors: Loic Kraemer Bastos, Zhengyao Li, and Aidan Sheehan
 * Date: 2026-02-17
 * CS3540
 */

import java.awt.AWTException;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import java.awt.Point;
import java.awt.Component;

int margin = 200;
final int padding = 50;
final int buttonSize = 40;
final int expandedHitbox = 90; // bigger hitbox for easier clicking

ArrayList<Integer> trials = new ArrayList<Integer>();
int trialNum = 0;
int startTime = 0;
int finishTime = 0;
int hits = 0;
int misses = 0;
int numRepeats = 1;

// Radial Layout
boolean radialMode = false;
final int centerButtonRadius = 18;

final int numButtons = 16;
final float offset = PI / numButtons;
int radius;
int innerRadius;
float translateX;
float translateY;
PVector center;

int hoveredButtonID = -1;
boolean debugCollision = false;

Robot robot;

void snapMouseToCenter() {
  Component canvas = (Component) surface.getNative();
  Point topLeft = canvas.getLocationOnScreen();

  int sx = topLeft.x + width/2;
  int sy = topLeft.y + height/2;

  robot.mouseMove(sx, sy);
}

void settings() {
  size(700, 700);
}

void setup() {
  noStroke();
  textFont(createFont("Arial", 16));
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER);

  try { robot = new Robot(); } 
  catch (AWTException e) { e.printStackTrace(); }

  // random button trials
  for (int i = 0; i < numButtons; i++)
    for (int k = 0; k < numRepeats; k++)
      trials.add(i);
  Collections.shuffle(trials);

  radius = width / 3;
  innerRadius = radius / 8;
  center = new PVector(width/2, height/2);
  translateX = center.x;
  translateY = center.y;

  // move mouse to center initially
  // robot.mouseMove(int(center.x) + 7, int(center.y) + 30);
  snapMouseToCenter();
}

void draw() {
  background(0);

  // RESULTS SCREEN
  if (trialNum >= trials.size()) {
    float timeTaken = (finishTime - startTime) / 1000f;
    float penalty = constrain(((95f - ((float) hits * 100f / (float) (hits + misses))) * .2f), 0, 100);
    fill(255);
    text("Finished!", width / 2, height / 2);
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float) hits * 100f / (float) (hits + misses) + "%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time per button: " + nf((timeTaken) / (float) (hits + misses), 0, 3) + " sec", width / 2, height / 2 + 100);
    text("Average time + penalty: " + nf((timeTaken) / (float) (hits + misses) + penalty, 0, 3) + " sec", width / 2, height / 2 + 140);
    return;
  }

  fill(255);
  text((trialNum + 1) + " of " + trials.size(), 40, 20);
  text(radialMode ? "MODE: Radial (press C to exit)" : "MODE: 4x4 (press C for radial)", width/2, 20);

  drawModeChangeButton();

  // compute hover for radial mode only
  hoveredButtonID = radialMode ? testButtonCollision(mouseX, mouseY) : -1;

  for (int i = 0; i < numButtons; i++)
    drawButton(i);

  if (!radialMode) makeTargetBlue(trials.get(trialNum));

  // visual cursor
  fill(255, 0, 0, 200);
  ellipse(mouseX, mouseY, 20, 20);
}

void drawButton(int i) {
  if (radialMode) {
    PShape button = getButtonBounds(i);
    boolean isTarget = (trials.get(trialNum) == i);
    boolean isHover  = (hoveredButtonID == i);
    if (isTarget && isHover) button.setFill(color(0, 255, 0));
    else if (isTarget) button.setFill(color(0, 255, 255));
    else if (isHover) button.setFill(color(255, 160, 0));
    else button.setFill(color(200));
    shape(button);
  } 
  else {
    // 4x4 hover effects
    PVector pos = getButtonLocation(i);
    int centerX = int(pos.x) + buttonSize/2;
    int centerY = int(pos.y) + buttonSize/2;

    boolean isHovered = (abs(mouseX - centerX) < expandedHitbox/2 &&
                         abs(mouseY - centerY) < expandedHitbox/2);

    int currentSize = buttonSize;
    float xOffset = 0;

    if (isHovered) {
      fill(255, 255, 100); // color change
      currentSize += 30;    // growth
      xOffset = sin(frameCount * 0.5f) * 2; // shake
    } 
    else fill(200);

    int offset = (currentSize - buttonSize)/2;
    rect(pos.x + xOffset - offset, pos.y - offset, currentSize, currentSize);
  }
}

void mousePressed() {
  if (trialNum >= trials.size()) return;
  if (trialNum == 0) startTime = millis();

  int targetID = trials.get(trialNum);
  int selectedID = radialMode ? testButtonCollision(mouseX, mouseY) : getSelectedButton(mouseX, mouseY);

  if (selectedID == targetID) hits++;
  else misses++;

  if (trialNum == trials.size()-1) finishTime = millis();
  trialNum++;

  // reset mouse to center after click
  // robot.mouseMove(int(center.x) + 7, int(center.y) + 30);
  snapMouseToCenter();

}

int getSelectedButton(int mX, int mY) {
  for (int i = 0; i < numButtons; i++) {
    PVector pos = getButtonLocation(i);
    int centerX = int(pos.x) + buttonSize/2;
    int centerY = int(pos.y) + buttonSize/2;

    if (abs(mX - centerX) < expandedHitbox/2 &&
        abs(mY - centerY) < expandedHitbox/2) {
      return i;
    }
  }
  return -1;
}

PVector getButtonLocation(int i) {
  int x = (i % 4) * (padding + buttonSize) + margin;
  int y = (i / 4) * (padding + buttonSize) + margin;
  return new PVector(x, y);
}

PShape getButtonBounds(int i) {
  PShape button = createShape();
  button.beginShape(QUADS);
  int x1, y1, x2, y2, x3, y3, x4, y4;
  x1 = int(cos((TWO_PI/numButtons)*i + HALF_PI + offset) * radius + translateX);
  y1 = int(sin((TWO_PI/numButtons)*i + HALF_PI + offset) * radius + translateY);
  x2 = int(cos((TWO_PI/numButtons)*i + HALF_PI - offset) * radius + translateX);
  y2 = int(sin((TWO_PI/numButtons)*i + HALF_PI - offset) * radius + translateY);
  x3 = int(cos((TWO_PI/numButtons)*i + HALF_PI - offset) * innerRadius + translateX);
  y3 = int(sin((TWO_PI/numButtons)*i + HALF_PI - offset) * innerRadius + translateY);
  x4 = int(cos((TWO_PI/numButtons)*i + HALF_PI + offset) * innerRadius + translateX);
  y4 = int(sin((TWO_PI/numButtons)*i + HALF_PI + offset) * innerRadius + translateY);

  button.vertex(x1, height - y1);
  button.vertex(x2, height - y2);
  button.vertex(x3, height - y3);
  button.vertex(x4, height - y4);
  button.endShape();
  return button;
}

int testButtonCollision(int locX, int locY) {
  if (radialMode) {
    float deltaX = width/2 - locX;
    float deltaY = height/2 - locY;
    float distance = sqrt(sq(deltaX) + sq(deltaY));
    if (distance > radius || distance < innerRadius) return -1;

    for (int i = 0; i < numButtons; i++) {
      float x1 = cos((TWO_PI/numButtons)*i + HALF_PI + offset);
      float y1 = sin((TWO_PI/numButtons)*i + HALF_PI + offset);
      float x2 = cos((TWO_PI/numButtons)*i + HALF_PI - offset);
      float y2 = sin((TWO_PI/numButtons)*i + HALF_PI - offset);
      PVector start = new PVector(x1, y1);
      PVector end   = new PVector(x2, y2);
      start.normalize();
      end.normalize();
      PVector loc = new PVector(locX - translateX, -(locY - translateY));
      loc.normalize();
      if (PVector.angleBetween(start, loc) < 2*offset && PVector.angleBetween(end, loc) < 2*offset) return i;
    }
  }
  else {
    return getSelectedButton(locX, locY);
  }
  return -1;
}

void makeTargetBlue(int i) {
  fill(0, 255, 255);
  PVector pos = getButtonLocation(i);
  rect(pos.x, pos.y, buttonSize, buttonSize);
}

void drawModeChangeButton() {
  fill(#AE47FF);
  circle(width/2, height/2, 2*centerButtonRadius);
}

void mouseMoved() {}
void mouseDragged() {}
void keyPressed() {
  if (key == 'c') radialMode = !radialMode;
}
