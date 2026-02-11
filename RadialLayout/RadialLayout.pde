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

boolean radialMode = false;

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

// you can change this code. Right now, it looks at the input location, and then checks if that location is within the bounds of 
// a button. If so, it returns the button ID. You can do something else to decide what button the user is selecting.
public int getSelectedButton(int locX, int locY) {
	for (int i = 0; i < 16; i++) {
		Rectangle bounds = getButtonBounds(i);

    // Test for hitbox collision
		if ((locX > bounds.x && locX < bounds.x + bounds.width) && (locY > bounds.y && locY < bounds.y + bounds.height))
			return i;
	}
	// returns -1 if the click was not on a button
	return -1;
}

void mousePressed() {
  if (trialNum >= trials.size())
    return;

  if (trialNum == 0)
    startTime = millis();

  if (trialNum == trials.size() - 1) 
    finishTime = millis();
  

  int targetID = trials.get(trialNum);
  int selectedButtonID = getSelectedButton(mouseX, mouseY);
  if(selectedButtonID == targetID){
    System.out.println("HIT! Trial:" + trialNum + ". Target: "+targetID+". Cumulative time:" + (millis() - startTime)); // success
    hits++;
  } else {
    System.out.println("MISSED! Trial:" + trialNum + ". Selected "+selectedButtonID+" but target was "+targetID+". Cumulative time:" + (millis() - startTime)); // fail
    misses++;
  }

  trialNum++;
}

Rectangle getButtonBounds(int i) {
  int x = (i % 4) * (padding + buttonSize) + margin;
  int y = (i / 4) * (padding + buttonSize) + margin;
  return new Rectangle(x, y, buttonSize, buttonSize);
}

void drawButton(int i) {
  Rectangle bounds = getButtonBounds(i);

  fill(200);

  if (trials.get(trialNum) == i) // Strictly for changing target's color. Do not modify
    fill(0, 255, 255);

  rect(bounds.x, bounds.y, bounds.width, bounds.height);
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
void keyPressed() {}
