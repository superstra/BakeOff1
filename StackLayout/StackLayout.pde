/**
 * Bake Off 1: Phase 2
 * Authors: Loic Kraemer Bastos, Zhengyao Li, and Aidan Sheehan
 * Date: 2026-02-15
 * CS3540
 * 
 * Vertical Stacked Layout
 */
import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;

int margin = 200; // grid layout margin
final int padding = 50; // grid spacing
final int buttonSize = 40; // button width/height

ArrayList<Integer> trials = new ArrayList<Integer>();
int trialNum = 0;
int startTime = 0;
int finishTime = 0;
int hits = 0;
int misses = 0;

Robot robot;
int numRepeats = 1;

// stacked layout + virtual cursor
boolean stackMode = false; // toggled by S key
float cursorX, cursorY; // virtual cursor
int hoveredIndex = -1; // which button is hovered in stack mode

// stacked layout placement
// final int stackX = 30; // left column x
// final int stackTop = 25; // top y
// final int stackGap = 2; // gap between stacked buttons

final int stackButtonW = 140; // width of each stacked rectangle
final int stackButtonH = 36; // height of each stacked rectangle
final int stackGap = 6; // gap between stacked rectangles
final int stackX = 30;
final int stackTop = 25;

void settings() {
  size(700, 700);
}

void setup() {
  noCursor();
  noStroke();
  textFont(createFont("Arial", 16));
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER);

  // init cursor at mouse position
  cursorX = mouseX;
  cursorY = mouseY;

  try {
    robot = new Robot();
  } catch (AWTException e) {
    e.printStackTrace();
  }

  for (int i = 0; i < 16; i++)
    for (int k = 0; k < numRepeats; k++)
      trials.add(i);

  Collections.shuffle(trials);
  println("trial order: " + trials);

  surface.setLocation(0, 0);
}

void draw() {
  background(0);

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

  // update virtual cursor + hover
  updateVirtualCursor();
  hoveredIndex = (stackMode) ? getHoveredButtonIndex(cursorX, cursorY) : -1;

  // UI text
  fill(255);
  text((trialNum + 1) + " of " + trials.size(), 60, 20);
  text(stackMode ? "MODE: STACK (press S to exit)" : "MODE: GRID (press S for stack)", width/2, 20);

  // draw buttons
  for (int i = 0; i < 16; i++)
    drawButton(i);

  // draw cursor
  fill(255, 0, 0, 200);
  ellipse(cursorX, cursorY, 20, 20);
}

void updateVirtualCursor() {
  if (!stackMode) {
    cursorX = mouseX;
    cursorY = mouseY;
    return;
  }

  // lock X to the center of the rectangle column
  cursorX = stackX + stackButtonW * 0.5f;

  // clamp Y to the full vertical span of the stack rectangles
  float top = stackTop;
  float bottom = stackTop + 16 * stackButtonH + 15 * stackGap;
  cursorY = constrain(mouseY, top, bottom);
}

int getHoveredButtonIndex(float x, float y) {
  for (int i = 0; i < 16; i++) {
    Rectangle b = getButtonLocation(i);
    if (x > b.x && x < b.x + b.width && y > b.y && y < b.y + b.height) {
      return i;
    }
  }
  return -1;
}

void mousePressed() {
  if (trialNum >= trials.size())
    return;

  if (trialNum == 0)
    startTime = millis();

  if (trialNum == trials.size() - 1) {
    finishTime = millis();
    println("we're all done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

  // use virtual cursor, not mouseX/mouseY
  if ((cursorX > bounds.x && cursorX < bounds.x + bounds.width)
      && (cursorY > bounds.y && cursorY < bounds.y + bounds.height)) {
    println("HIT! " + trialNum + " " + (millis() - startTime));
    hits++;
  } else {
    println("MISSED! " + trialNum + " " + (millis() - startTime));
    misses++;
  }

  trialNum++;
}

Rectangle getButtonLocation(int i) {
  if (!stackMode) {
    int x = (i % 4) * (padding + buttonSize) + margin;
    int y = (i / 4) * (padding + buttonSize) + margin;
    return new Rectangle(x, y, buttonSize, buttonSize);
  } else {
    int x = stackX;
    int y = stackTop + i * (stackButtonH + stackGap);
    return new Rectangle(x, y, stackButtonW, stackButtonH);
  }
}

void drawButton(int i) {
  Rectangle bounds = getButtonLocation(i);

  boolean isTarget = (trials.get(trialNum) == i);
  boolean isHover = (stackMode && hoveredIndex == i);

  // target button = cyan
  // hovered button = orange
  // if both target + hovered = green
  if (isTarget && isHover) fill(0, 255, 0);
  else if (isTarget) fill(0, 255, 255);
  else if (isHover) fill(255, 160, 0);
  else fill(200);

  rect(bounds.x, bounds.y, bounds.width, bounds.height);
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    stackMode = !stackMode;

    // when entering stack mode, snap cursor into the stack column immediately
    if (stackMode) {
      cursorX = stackX + buttonSize * 0.5f;
      float top = stackTop;
      float bottom = stackTop + (16 * buttonSize) + (15 * stackGap);
      cursorY = constrain(mouseY, top, bottom);
    } else {
      // leaving stack mode, resume normal cursor behavior
      cursorX = mouseX;
      cursorY = mouseY;
      hoveredIndex = -1;
    }
  }
}

void mouseMoved() {}
void mouseDragged() {}
