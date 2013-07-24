//timeline mockup
//Timo Bleeker - July 2013

/** This is a timeline mockup that can be used to implement new interaction techniques. 
 ** Touch event code is based on work by Mark Billinghurst.
 */

import android.view.MotionEvent;

ArrayList<Card> cards = new ArrayList<Card>();
int max_cards = 8;             // Amount of Cards. Make sure there are enough images named 0.jpg to n.jpg

float translation; 
float target_translation;
float offset;
int start_card = 3;            // Card that will be shown on Startup
int target_card = start_card;  // The next card that will be shown on UP event
int current_card = start_card; // The card currently in view 
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
  
  //on UP event, motion tween to target card
  if (touchEvent == "UP") {
    for (int i = 0; i < max_cards; i++) {
      translation += (target_translation - translation)/tween_speed;
      cards.get(i).setLocation((int)(translation + cards.get(i).size.x * i), 0);
      cards.get(i).drawImage();
    }
  } 
  else {
    //if there's no UP event yet, translate cards according to finger movement
    for (int i = 0; i < max_cards; i++) {
      cards.get(i).setLocation((int)(translation + cards.get(i).size.x * i), 0);
      cards.get(i).drawImage();
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
      int loc = (int)cards.get(i).location.x;
      if (loc > -25 && loc < 25) {
        current_card = i;
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
    translation = dx + offset;
    translation = -translation;
    break;

    //touch up event
  case MotionEvent.ACTION_UP:
    touchEvent = "UP";
    fingerTouch = 0;
    
    //simple way to check wether we swiped forward or backward on the touchpad   
    if (dx > stickiness) {
      //we swiped forwards
      if (current_card != max_cards-1)
        target_card = current_card + 1;
    } 
    else if (dx < -stickiness) {
      //we swiped backwards
      if (current_card != 0)
        target_card = current_card - 1;
    }
    
    //update target_translation for the motion tween
    target_translation = -target_card * cards.get(0).size.x;
    offset = -target_translation; 
    break;

    //other events 
  default:
    touchEvent = "OTHER (CODE " + action + ")";  // default text on other event
  } 

  return super.dispatchTouchEvent(event);        // pass data along when done!
}

