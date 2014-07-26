//gestures.pde
//Timo Bleeker - July 2013

/*this demo is based on Mark Billinghurst work on capturing Glass touchpad input in processing.
 Additionally this demo outputs what gesture is made
 */

//need to import an Android class to catch all the motion events
import android.view.MotionEvent;

//Screen and pad dimensions
int myScreenWidth = 640;
int myScreenHeight = 360;
int padWidth = 1366;
int padHeight = 187;

//Touch event stuff
String touchEvent = ""; // string for the touch event type
int fingerTouch;
float down_x, down_y, up_x, up_y;


//scale factors
float touchPadScaleX;
float touchPadScaleY;
float xpos, ypos;

//variable background color to show touches
color bg_color = color(0, 0, 0);

void setup() {

  size(640, 360);
  down_x = 0;
  down_y = 0;
  up_x = 0;
  up_y = 0;
  //set the touch scale factor
  touchPadScaleX = (float)myScreenWidth/padWidth;
  touchPadScaleY = (float)myScreenHeight/padHeight;
}

void draw() {
  // Draw on black background
  background(bg_color); 

  //draw red circle when the user is touching the screen
  if (fingerTouch==1) {
    fill(255, 0, 0, 100);
    ellipse(xpos, ypos, 50, 50);
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
    //xpos = myScreenWidth-x*touchPadScaleX;
    //ypos = y*touchPadScaleY;
    down_x = x;
    down_y = y;
    fingerTouch = 1;
   // bg_color = color(0, 255, 0);

    break;

    //touch up event
  case MotionEvent.ACTION_UP:
    touchEvent = "UP";
    fingerTouch = 0;
    up_x = x;
    up_y = y;
    //bg_color = color(0, 0, 0);
    break;

    //move touch event
  case MotionEvent.ACTION_MOVE:
    touchEvent = "MOVE";
    xpos = myScreenWidth-x*touchPadScaleX;
    ypos = y*touchPadScaleY;
    fingerTouch = 1;
    // bg_color = color(0,0,255);
    break;

    //other events 
  default:
    touchEvent = "OTHER (CODE " + action + ")";  // default text on other event
  }

  return super.dispatchTouchEvent(event);        // pass data along when done!
}


