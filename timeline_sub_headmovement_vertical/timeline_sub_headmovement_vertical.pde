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

//timeline with submenu - Gyro control - absolute vertical
//Timo Bleeker - August 2013

/** This timeline mockup uses normal swiping gestures to switch cards in the main timeline.
 ** The Clock card has a vertical submenu accessed by tapping while on the clock card.
 ** The submenu is navigated through by looking up and down.
 ** This is very uncomfortable for large menu's. However, it could be useful for a menu that just has 2 options:
 ** For instance a yes / no menu which shows a yes card when looking down, and a no card when looking up.
 ** Touch event code is based on work by Mark Billinghurst.
 **
 */

import apwidgets.*;
import ketai.sensors.*;
import android.view.MotionEvent;
KetaiSensor sensor;

ArrayList<Card> cards = new ArrayList<Card>();

int max_cards = 8;

PVector translation;
PVector target_translation;
PVector offset;
PVector gyro;
int gyro_speed = 200; // Amount of translation per gyro unit. Higher means faster translation

boolean submenu;

int start_card = 3;            // Card that will be shown on Startup
int target_card;  // The next card that will be shown on UP event
int current_card;
int current_sub_card;
int target_sub_card;

int stickiness = 50;     // The dx that has to be detected before we move to the next/prev card. Higher means we need to swipe more
int tween_speed = 20;
int moves = 0;
int speed = 20;

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

//audio events
APMediaPlayer player;

void setup() {
  frameRate(30);
  translation = new PVector(0, 0);
  target_translation = new PVector(0, 0);
  offset = new PVector(0, 0);

  sensor = new KetaiSensor(this);
  gyro = new PVector();
  //set up cards
  target_card = start_card;  // The next card that will be shown on UP event
  current_card = start_card;// The card currently in view

  submenu = false;

  //set the touch scale factor
  touchPadScaleX = (float)myScreenWidth/padWidth;
  touchPadScaleY = (float)myScreenHeight/padHeight;

  //load the images
  for (int i = 0; i <= max_cards; i++) {
    cards.add(new Card(i + ".jpeg", i));
  }

  //add menu cards for card 3
  for (int i = 0; i < 7; i++) {
    cards.get(3).addChild("3-" + i + ".jpeg", 3, i);
  }

  //set the initial translation to show the start_card
  translation.x = -start_card * cards.get(0).size.x;
  offset.x = -translation.x;

  //draw the cards in their initial position
  for (int i = 0; i < max_cards; i++) {
    int loc = (int)(translation.x + cards.get(i).size.x * i);
    cards.get(i).setLocation(loc, 0);
    cards.get(i).drawImage();
  }

  player = new APMediaPlayer(this); //create new APMediaPlayer
  player.setMediaFile("focus.mp3"); //set the file (files are in data folder)
  player.start(); //start play back
  //player.setLooping(true); //restart playback end reached
  player.setVolume(1.0, 1.0); //Set left and right volumes. Range is from 0.0 to 1.05
}

void draw() {
  background(0);
  println(translation.x);
  //on UP event, motion tween to target card
  if (touchEvent == "UP") {
    if (!submenu) {
      for (int i = 0; i < max_cards; i++) {
        translation.x += (target_translation.x - translation.x)/tween_speed;
        int loc = (int)(translation.x + cards.get(i).size.x * i);
        cards.get(i).setLocation(loc, 0);
        cards.get(i).drawImage();
      }
    }
    else {
      if (sensor.isStarted()) {
        if (translation.y >= 0 && gyro.x > 0 ) {
          translation.y = 0;
        }
        else if (translation.y <= -cards.get(0).size.y * (cards.get(current_card).children - 1) && gyro.x < 0) {
          translation.y = -cards.get(0).size.y * (cards.get(current_card).children - 1);
        }
        else {
          translation.y += gyro.x * gyro_speed;
        }
      }
      for (int j = 0; j < cards.get(current_card).children; j++) {
        int sub_loc_y = (int)(translation.y + cards.get(j).size.y * j);
        cards.get(current_card).child_cards.get(j).setLocation(0, sub_loc_y);
        cards.get(current_card).child_cards.get(j).drawImage();
      }
    }
  }
  else {
    //if there's no UP event yet, translate cards according to finger movement
    if (!submenu) {
      for (int i = 0; i < max_cards; i++) {
        int loc = (int)(translation.x + cards.get(i).size.x * i);
        cards.get(i).setLocation(loc, 0 + (int)translation.y);
        cards.get(i).drawImage();
      }
    }
    else {
      if (sensor.isStarted()) {
        if (translation.y >= 0 && gyro.x > 0 ) {
          translation.y = 0;
        }
        else if (translation.y <= -cards.get(0).size.y * (cards.get(current_card).children - 1) && gyro.x < 0) {
          translation.y = -cards.get(0).size.y * (cards.get(current_card).children - 1);
        }
        else {
          translation.y += gyro.x * gyro_speed;
        }
      }
      for (int j = 0; j < cards.get(current_card).children; j++) {
        int sub_loc_y = (int)(translation.y + cards.get(j).size.y * j);
        cards.get(current_card).child_cards.get(j).setLocation(0, sub_loc_y);
        cards.get(current_card).child_cards.get(j).drawImage();
      }
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
    //check what card is in view on the DOWN event to update the current card.
    if (!submenu) {
      for (int i = 0; i < max_cards; i++) {
        int loc_x = (int)cards.get(i).location.x;
        if (loc_x > -25 && loc_x < 25) {
          current_card = i;
        }
      }
    }
    else {
      for (int i = 0; i < cards.get(current_card).child_cards.size(); i++) {
        int loc_y = (int) cards.get(current_card).child_cards.get(i).location.y;
        if (loc_y > -25 && loc_y < 25) {
          current_sub_card = i;
        }
      }
    }

    break;

    //move touch event
  case MotionEvent.ACTION_MOVE:
    touchEvent = "MOVE";
    xpos = myScreenWidth-x*touchPadScaleX;
    ypos = y*touchPadScaleY;
    fingerTouch = 1;
    //update the translation for live feedback
    dx = x_start - xpos;
    if (!submenu) {
      translation.x = dx + offset.x;
      translation.x = -translation.x;
    }

    //to differentiate between taps and swipes we check how often the MOVE MotionEvent is given
    moves++;

    break;

    //touch up event
  case MotionEvent.ACTION_UP:
    touchEvent = "UP";
    fingerTouch = 0;

    //simple way to check wether we swiped forward or backward on the touchpad
    if (dx > stickiness && !submenu) {
      //we swiped forwards
      if (current_card != max_cards-1){
        target_card = current_card + 1;
        player.start();
      }
    }
    else if (dx < -stickiness && !submenu) {
      //we swiped backwards
      if (current_card != 0){
        target_card = current_card - 1;
        player.start();
      }
    }

    //update target_translation for the motion tween
    target_translation.x = -target_card * cards.get(0).size.x;
    offset.x = -target_translation.x;

    //if the MOVE motionEvent was given less than 5 times, the user probably wanted to tap. Change menu mode.
    if (!submenu && moves < 5 && cards.get(current_card).children != 0 ) {
      submenu = true;
      translation.x = 0;
      sensor.start();
      moves = 0;
    }
    else if (submenu && moves < 5) {
      submenu = false;
      translation.x = -cards.get(current_card).size.x * current_card;
      sensor.stop();
      moves = 0;
    }
    else {
      moves = 0;
    }

    break;

    //other events
  default:
    touchEvent = "OTHER (CODE " + action + ")";  // default text on other event
  }

  return super.dispatchTouchEvent(event);        // pass data along when done!
}

void onGyroscopeEvent(float x, float y, float z, long time, int accuracy) {
  gyro.set(x, y, z);
}
