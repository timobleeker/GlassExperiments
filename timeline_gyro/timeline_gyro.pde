//timeline mockup
//Timo Bleeker - July 2013

import android.view.MotionEvent;

import ketai.ui.*;
import ketai.sensors.*;

KetaiSensor sensor;
KetaiGesture gesture;

PImage[] images = new PImage[6];
PVector gyro;
float rotation;
int speed = 40;

void setup() {
  sensor = new KetaiSensor(this);
  gesture = new KetaiGesture(this);
  sensor.start();
  sensor.list();
  gyro = new PVector();
  orientation(LANDSCAPE);
  for (int i = 0; i < images.length; i++) {
    images[i] = loadImage(i + ".jpg");
  }
}

void draw() {
  background(0);

  if (sensor.isStarted()) {
    //for glass use gyro.y, for phone use gyro.x
    rotation+=gyro.y*speed;
    
  } else {
    rotation = rotation / images[0].width; 
    rotation = round(rotation);
    rotation = rotation * images[0].width;   
  }

  for (int i = 0; i < images.length; i++) {
    image(images[i], rotation + images[i].width * i, 0);
  }
}

void onGyroscopeEvent(float x, float y, float z, long time, int accuracy) {
  gyro.set(x, y, z);
}

//for glass
void keyPressed() {
  // doing other things here, and then:
  print("key = "+key);
  if (key == CODED) {
    print("keypress = "+key);
    if (keyCode == DPAD) {
      // user pressed the center button on the d-pad
      print("center");
      if (sensor.isStarted()) {
        sensor.stop();
      } 
      else {
        sensor.start();
      }
    }
  }
}


//for phones

void onTap(float x, float y)
{
  if (sensor.isStarted()) {
        sensor.stop();
      } 
      else {
        sensor.start();
      }
  println("tap");
}

public boolean surfaceTouchEvent(MotionEvent event) {

  //call to keep mouseX, mouseY, etc updated
  super.surfaceTouchEvent(event);

  //forward event to class for processing
  return gesture.surfaceTouchEvent(event);
}


