/*
* Copyright, 2013, 2014, by Timo Bleeker
*
* This collection of experiments is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This collection is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//timeline mockup
//Timo Bleeker - July 2013

/** This is a timeline mockup that can be used to implement new interaction techniques.
 ** It has no tweens, just simple snapping to the closest card.
 ** Touch event code is based on work by Mark Billinghurst
 */

import android.view.MotionEvent;

PImage[] images = new PImage[8];
float rotation;
float target_rotation;
float offset = 0;
int start_image = 3;
int focus_image = 3;

//Screen and pad dimensions
int myScreenWidth = 640;
int myScreenHeight = 360;
int padWidth = 1366;
int padHeight = 187;

//Touch event stuff
String touchEvent = ""; // string for the touch event type
int fingerTouch;
float x_start;
float dx;

//scale factors
float touchPadScaleX;
float touchPadScaleY;
float xpos, ypos;

void setup() {

  //size(myScreenWidth, myScreenHeight);

  //set the touch scale factor
  touchPadScaleX = (float)myScreenWidth/padWidth;
  touchPadScaleY = (float)myScreenHeight/padHeight;

  //load the images
  for (int i = 0; i < images.length; i++) {
    images[i] = loadImage(i + ".jpg");
  }
}

void draw() {
  background(0);

  if (touchEvent == "UP") {
    for (int i = 0; i < images.length; i++) {
      rotation += (target_rotation - rotation)/20;
      image(images[i], rotation + images[i].width * i - images[i].width * start_image, 0);
    }
  }
  else {
    for (int i = 0; i < images.length; i++) {
      image(images[i], rotation + images[i].width * i - images[i].width *  start_image, 0);
    }
  }
}

//Glass Touch Events - reads from touch pad
public boolean dispatchGenericMotionEvent(MotionEvent event) {
  float x = event.getX();                         // get x/y coords of touch event
  float y = event.getY();
  int action = event.getActionMasked();          // get code for action

  //no finger touch yet
  fingerTouch = 0;

  switch (action) {                              // let us know which action code shows up
    //touch down event
  case MotionEvent.ACTION_DOWN:
    touchEvent = "DOWN";
    xpos = myScreenWidth-x*touchPadScaleX;
    ypos = y*touchPadScaleY;
    fingerTouch = 1;
    x_start = xpos;
    println("DOWN");
    break;

    //move touch event
  case MotionEvent.ACTION_MOVE:
    touchEvent = "MOVE";
    xpos = myScreenWidth-x*touchPadScaleX;
    ypos = y*touchPadScaleY;
    fingerTouch = 1;
    dx = x_start - xpos;
    rotation = dx + offset;
    println("MOVE");
    break;

    //touch up event
  case MotionEvent.ACTION_UP:
    touchEvent = "UP";
    fingerTouch = 0;
    float card = round(rotation / images[0].width);


    if (card < -(images.length - 1) + start_image) {
      println("Reached end");
      target_rotation = (card +1) * images[0].width;
    }
    else if (card > start_image ) {
      println("Reached end");
      target_rotation = (card - 1) * images[0].width;
    }
    else {
      target_rotation = card * images[0].width;
    }

    offset = target_rotation;
    println("UP");
    break;


    //other events
  default:
    touchEvent = "OTHER (CODE " + action + ")";  // default text on other event
  }

  return super.dispatchTouchEvent(event);        // pass data along when done!
}
