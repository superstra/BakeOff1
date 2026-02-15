/**
 * Bake Off 1: Phase 2
 * Authors: Loic Kraemer Bastos, Zhengyao Li, and Aidan Sheehan
 * Date: 2026-02-11
 * CS3540
 * 
 * Hover Effects prototype
 */

import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;

// CONFIGURATION
int margin = 200; 
final int padding = 50; 
final int buttonSize = 40; 
final int expandedHitbox = 90; // Selection area is bigger than what we can see

ArrayList<Integer> trials = new ArrayList<Integer>(); 
int trialNum = 0; 
int startTime = 0; 
int finishTime = 0; 
int hits = 0; 
int misses = 0; 
int numRepeats = 1; 

void setup() {
  size(700, 700);
  noStroke();
  textFont(createFont("Arial", 16));
  textAlign(CENTER);
  frameRate(60);

  for (int i = 0; i < 16; i++)
    for (int k = 0; k < numRepeats; k++)
      trials.add(i);

  Collections.shuffle(trials);
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
    text("Average time for each button: " + nf((timeTaken) / (float) (hits + misses), 0, 3) + " sec",
         width / 2, height / 2 + 100);
    text("Average time for each button + penalty: "
         + nf(((timeTaken) / (float) (hits + misses) + penalty), 0, 3) + " sec",
         width / 2, height / 2 + 140);
    return;
  }

  fill(255);
  text((trialNum + 1) + " of " + trials.size(), 40, 20);

  // Draw buttons with Hover Effects
  for (int i = 0; i < 16; i++)
    drawButton(i);

  // Highlight Target
  makeTargetBlue(trials.get(trialNum));

  // Visual Cursor
  fill(255, 0, 0, 200);
  ellipse(mouseX, mouseY, 20, 20);
}

// INTERACTION DESIGN 

void drawButton(int i) {
  Rectangle bounds = getButtonLocation(i);
  int centerX = bounds.x + (buttonSize / 2);
  int centerY = bounds.y + (buttonSize / 2);

  // Expanded check
  boolean isHovered = (abs(mouseX - centerX) < (expandedHitbox / 2) && 
                       abs(mouseY - centerY) < (expandedHitbox / 2));

  int currentSize = buttonSize;
  
  if (isHovered) {
    fill(255, 255, 100); // Color change
    currentSize += 30;    //Growth
    
    // shake effect
    float shake = sin(frameCount * 0.5f) * 2; 
    bounds.x += shake;
  } else {
    fill(200);
  }

  int offset = (currentSize - buttonSize) / 2;
  rect(bounds.x - offset, bounds.y - offset, currentSize, currentSize);
}

void mousePressed() {
  if (trialNum >= trials.size()) return;
  if (trialNum == 0) startTime = millis();

  // Selection uses the larger expanded hitbox
  int selectedID = getSelectedButton(mouseX, mouseY);
  int targetID = trials.get(trialNum);

  if (selectedID == targetID) {
    hits++;
  } else {
    misses++;
  }

  if (trialNum == trials.size() - 1) finishTime = millis();
  trialNum++;
}

int getSelectedButton(int mX, int mY) {
  for (int i = 0; i < 16; i++) {
    Rectangle bounds = getButtonLocation(i);
    int centerX = bounds.x + (buttonSize / 2);
    int centerY = bounds.y + (buttonSize / 2);
   
    // Make selection before the mouse is on the button
    if (abs(mX - centerX) < (expandedHitbox / 2) && 
        abs(mY - centerY) < (expandedHitbox / 2)) {
      return i;
    }
  }
  return -1;
}

void makeTargetBlue(int i) {    
  fill(0, 255, 255);
  Rectangle bounds = getButtonLocation(i);
  rect(bounds.x, bounds.y, buttonSize, buttonSize);
}

Rectangle getButtonLocation(int i) {
  int x = (i % 4) * (padding + buttonSize) + margin;
  int y = (i / 4) * (padding + buttonSize) + margin;
  return new Rectangle(x, y, buttonSize, buttonSize);
}
