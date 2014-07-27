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

//timeline mockup - Gyro control - absolute
//Timo Bleeker - July 2013

/** This timeline mockup uses absolute Gyro to look around the cards
 ** Move your head to scroll to cards. To moving your head changes the translation in an absolute manner.
 ** Stop and start the sensor with a tap on the touchpad. The card that's more than half on the screen will snap.
 **
 ** Touch event code is based on work by Mark Billinghurst.
 ** I left the the touch code in, for easy hacking
 **
 */

import android.view.MotionEvent;
import ketai.sensors.*;

KetaiSensor sensor;

PVector gyro;
int gyro_speed = 100; // Amount of translation per gyro unit. Higher means faster translation

ArrayList<Card> cards = new ArrayList<Card>();
int max_cards = 8;             // Amount of Cards. Make sure there are enough images named 0.jpg to n.jpg

float translation;
float target_translation;
float offset;
int start_card = 3;            // Card that will be shown on Startup
int target_card = start_card;  // The next card that will be shown on UP event
int stickiness = 50;     // The dx that has to be detected before we move to the next/prev card. Higher means we need to swipe more
int tween_speed = 20;

//Screen and pad dimensions
int myScreenWidth = 640;
int myScreenHeight = 360;
int padWidth = 1366;
int padHeight = 187;

//Touch events
String touchEvent = ""; // string for the touch event type
int fingerTouch;
float x_start;
float dx;

//scale factors
float touchPadScaleX;
float touchPadScaleY;
float xpos, ypos;

void setup() {
  orientation(LANDSCAPE);

  sensor = new KetaiSensor(this);
  sensor.start();
  sensor.list();
  gyro = new PVector();

  //set the touch scale factor
  touchPadScaleX = (float)myScreenWidth/padWidth;
  touchPadScaleY = (float)myScreenHeight/padHeight;

  //load the images
  for (int i = 0; i <= max_cards; i++) {
    cards.add(new Card(i + ".jpg", i));
  }

  //set the initial translation to show the start_card
  translation = -start_card * cards.get(0).size.x;
  offset = -translation;

  //draw the cards in their initial position
  for (int i = 0; i < max_cards; i++) {
    cards.get(i).setLocation((int)(translation + cards.get(i).size.x * i), 0);
    cards.get(i).drawImage();
  }
}

void draw() {
  background(0);

  if (sensor.isStarted()) {
    if (translation >= 0 && gyro.y > 0 ) {
      translation = 0;
    }
    else if (translation <= -cards.get(0).size.x * (max_cards - 1) && gyro.y < 0) {
      translation = -cards.get(0).size.x * (max_cards - 1);
    }
    else {
      translation += gyro.y * gyro_speed;
    }
    for (int i = 0; i < max_cards; i++) {
      cards.get(i).setLocation((int)(translation + cards.get(i).size.x * i), 0);
      cards.get(i).drawImage();
    }
  }
  else {
    //snap if the sensor is stopped
    for (int i = 0; i < max_cards; i++) {
      translation += (target_translation - translation)/tween_speed;
      cards.get(i).setLocation((int)(translation + cards.get(i).size.x * i), 0);
      cards.get(i).drawImage();
    }
  }
}
void onGyroscopeEvent(float x, float y, float z, long time, int accuracy) {
  gyro.set(x, y, z);
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

    break;

    //move touch event
  case MotionEvent.ACTION_MOVE:
    touchEvent = "MOVE";
    xpos = myScreenWidth-x*touchPadScaleX;
    ypos = y*touchPadScaleY;
    fingerTouch = 1;
    //update the translation for live feedback

    break;

    //touch up event
  case MotionEvent.ACTION_UP:
    touchEvent = "UP";
    fingerTouch = 0;
    if (!sensor.isStarted()) {
      sensor.start();
    }
    else {
      sensor.stop();
      target_translation = round(translation / cards.get(0).size.x) * cards.get(0).size.x;
    }
    break;

    //other events
  default:
    touchEvent = "OTHER (CODE " + action + ")";  // default text on other event
  }

  return super.dispatchTouchEvent(event);        // pass data along when done!
}
