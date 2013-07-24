//
//Timo Bleeker - July 2013

/** 
 */

import ketai.sensors.*;

KetaiSensor sensor;
PVector orientation;

void setup()
{

  sensor = new KetaiSensor(this);
  sensor.start();
  orientation = new PVector();

  size(640, 360, P3D);
  background(0);
}

void draw() {
  pushMatrix();
  background(0);
  strokeWeight(1);
  stroke(255);
  translate(displayWidth/2, displayHeight/2, -200);
  for (int i=-150;i<170;i+=20)
  {
    pushMatrix();
    //rotateX(90);
    stroke(255, map(i, -150, 170, 255, 0), map(i, -150, 170, 255, 0));
    line(-150, i, 150, i);
    stroke(map(i, -150, 170, 255, 0), 255, map(i, -150, 170, 255, 0));
    line(i, -150, i, 150);
    popMatrix();
  }

  popMatrix();
}

void onOrientationEvent(float x, float y, float z, long time, int accuracy)
{
  orientation.set(x, y, z);
}

