//timeline Vertical Children
//Timo Bleeker - July 2013

/** This is a timeline that shows child cards (or cards within a bundle) in a vertical timeline. 
 ** I haven't figured out how to check if files exist with Processing for Android, since apparently
 ** the sketch data folder on android is not created. I currently don't know where it actually stores the images.
 ** Because of this, we have to load child cards manually (we can't check if they are there and then add them).
 ** Touch event code is based on work by Mark Billinghurst.
 */

import android.view.MotionEvent;

ArrayList<Card> cards = new ArrayList<Card>();

int max_cards = 8;             // Amount of Cards. Make sure there are enough images named 0.jpg to n.jpg

PVector translation; 
PVector target_translation;
PVector offset;
int start_card = 3;            // Card that will be shown on Startup
int target_card = start_card;  // The next card that will be shown on UP event
int current_card = start_card; // The card currently in view 
int target_card_y = 0;
int current_card_y = 0;
int stickiness = 50;     // The dx that has to be detected before we move to the next/prev card. Higher means we need to swipe more
int tween_speed = 20;
boolean scroll_vertical = false;
int moves = 0;

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
  translation = new PVector(0, 0);
  target_translation = new PVector(0, 0);
  offset = new PVector(0, 0);

  //set the touch scale factor
  touchPadScaleX = (float)myScreenWidth/padWidth;
  touchPadScaleY = (float)myScreenHeight/padHeight;

  //load the images
  for (int i = 0; i <= max_cards; i++) {
    cards.add(new Card(i + ".jpg", i));
  }

  //at the moment we have to add the child cards manually to each card with .addChild(String filename, int parentcard, int, cardnumber)
  cards.get(2).addChild("2-0.jpg", 2, 0);
  cards.get(3).addChild("3-0.jpg", 3, 0);
  cards.get(3).addChild("3-1.jpg", 3, 1);
  cards.get(3).addChild("3-2.jpg", 3, 2);

  //set the initial translation to show the start_card
  translation.x = -start_card * cards.get(0).size.x;
  offset.x = -translation.x; 

  //draw the cards in their initial position
  for (int i = 0; i < max_cards; i++) {
    cards.get(i).setLocation((int)(translation.x + cards.get(i).size.x * i), 0);
    cards.get(i).drawImage();
    for (int j = 0; j < cards.get(i).children; j++) {
      cards.get(i).child_cards.get(j).setLocation((int)cards.get(i).location.x, (int)cards.get(i).size.y * (j + 1));
      cards.get(i).child_cards.get(j).drawImage();
    }
  }
}


void draw() {
  background(0);

  //on UP event, motion tween to target card
  if (touchEvent == "UP") {
    for (int i = 0; i < max_cards; i++) {
      translation.x += (target_translation.x - translation.x)/tween_speed;
      cards.get(i).setLocation((int)(translation.x + cards.get(i).size.x * i), (int)translation.y);
      cards.get(i).drawImage();
      for (int j = 0; j < cards.get(i).children; j++) {
        if (scroll_vertical) {
          translation.y += (target_translation.y - translation.y)/(tween_speed - 10);
          cards.get(i).child_cards.get(j).setLocation((int)cards.get(i).location.x, (int)cards.get(i).size.y * (j + 1) + (int)translation.y);
          cards.get(i).child_cards.get(j).drawImage();
        }
      }
    }
  } 
  else {
    //if there's no UP event yet, translate cards according to finger movement
    for (int i = 0; i < max_cards; i++) {
      cards.get(i).setLocation((int)(translation.x + cards.get(i).size.x * i), 0 + (int)translation.y);
      cards.get(i).drawImage();
      for (int j = 0; j < cards.get(i).children; j++) {
        cards.get(i).child_cards.get(j).setLocation((int)cards.get(i).location.x, (int)cards.get(i).size.y * (j + 1)+ (int)translation.y);
        cards.get(i).child_cards.get(j).drawImage();
        //  println((int)cards.get(i).child_cards.get(j).location.y);
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
    for (int i = 0; i < max_cards; i++) {
      int loc_x = (int)cards.get(i).location.x;
      if (loc_x > -25 && loc_x < 25) {
        current_card = i;
      }
      for (int j = 0; j < cards.get(i).children; j++) {
        int loc_y = (int)cards.get(i).child_cards.get(j).location.y;
        println("loc_y" + loc_y);
        if (loc_y > -25 && loc_y < 25) {
          current_card_y = j + 1;
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
    if (!scroll_vertical) {

      translation.x = dx + offset.x;
      translation.x = -translation.x;
    } 
    else {
      translation.y = dx + offset.y;
      translation.y = -translation.y;
    }
    
    //to differentiate between taps and swipes we check how often the MOVE MotionEvent is given
    moves++;

    break;

    //touch up event
  case MotionEvent.ACTION_UP:
    touchEvent = "UP";
    fingerTouch = 0;

    //simple way to check wether we swiped forward or backward on the touchpad   
    if (dx > stickiness && !scroll_vertical) {
      //we swiped forwards
      if (current_card != max_cards-1)
        target_card = current_card + 1;
    } 
    else if (dx < -stickiness && !scroll_vertical) {
      //we swiped backwards
      if (current_card != 0)
        target_card = current_card - 1;
    } 
    else if (dx > stickiness && scroll_vertical) {
      //we swiped forwards
      if (current_card_y < cards.get(current_card).children) //change this to y max cards
        target_card_y = current_card_y + 1;
    } 
    else if (dx < -stickiness && scroll_vertical) {
      //we swiped backwards
      if (current_card_y != 0) {
        target_card_y = current_card_y - 1;
        if (target_card_y == 0) {
          current_card_y = 0;
        }
      }
    }
    println("current: " + current_card_y +  " target: " + target_card_y);

    //update target_translation for the motion tween
    target_translation.x = -target_card * cards.get(0).size.x;
    target_translation.y = -target_card_y * cards.get(0).size.y;
    //println(target_translation.y);
    offset.x = -target_translation.x; 
    offset.y = -target_translation.y; 

    //if the MOVE motionEvent was given less than 5 times, the user probably wanted to tap. Change scrolling mode.
    if (!scroll_vertical && moves < 5 && cards.get(current_card).children != 0 ) {
      scroll_vertical = true;
      moves = 0;
    } 
    else if (moves < 5) {
      scroll_vertical = false;
      translation.y = 0;
      offset.y = 0;
      target_translation.y = 0;
      current_card_y = 0;
      target_card_y = 0;
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

