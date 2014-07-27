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
