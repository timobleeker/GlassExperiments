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

//
//Timo Bleeker - July 2013

/**
 */

import ketai.sensors.*;


KetaiSensor sensor;
PVector orientation;

void setup()
{
  size(640, 360, P3D);
  background(0);

  sensor = new KetaiSensor(this);
  sensor.start();
  orientation = new PVector();
}

void draw() {

  println("rotX: " + orientation.x + " rotY: " + orientation.y + " rotZ: " + orientation.z);

  background(0);

  pushMatrix();
  translate(displayWidth/2, displayHeight/2, 300);
  rotateX(radians(-orientation.y - 180)); //pitch
  rotateY(radians(-orientation.z)); //roll
  rotateZ(radians(orientation.x)); //yaw

  strokeWeight(1);
  stroke(255);
  drawBoxes();
  drawGrid();
  popMatrix();

  drawCompass();
}

void onOrientationEvent(float x, float y, float z, long time, int accuracy)
{
  orientation.set(x, y, z);
}

void drawBoxes() {
  stroke(255);
  pushMatrix();
  rotateZ(radians(0));
  translate(0, 100, 50);
  fill(255, 255, 0);
  box(50);
  popMatrix();

  pushMatrix();
  rotateZ(radians(90));
  translate(0, 200, 50);
  fill(0, 255, 255);
  box(50);
  popMatrix();

  pushMatrix();
  rotateZ(radians(180));
  translate(0, 300, 50);
  fill(255, 0, 255);
  box(50);
  popMatrix();

  pushMatrix();
  rotateZ(radians(270));
  translate(0, 400, 50);
  fill(255, 0, 0);
  box(50);
  popMatrix();
}

void drawGrid() {
  for (int i=-1000;i<1040;i+=40)
  {
    pushMatrix();
    translate(0, 0, 100);
    stroke(0, 255, 0);
    line(-1000, i, 1000, i);
    stroke(255, 0, 0);
    line(i, -1000, i, 1000);
    popMatrix();
  }
}

void drawCompass() {
  strokeWeight(0);
  fill(255);
  rect(0, 0, displayWidth, 50);
  strokeWeight(1);
  stroke(0);
  fill(255, 0, 255);
  ellipse(displayWidth/2, 25, 20, 20);
  fill(255,0,0);
  ellipse(displayWidth/4, 25, 20, 20);
  fill(0, 255, 255);
  ellipse((displayWidth/4)*3, 25, 20, 20);
  fill(255, 255, 0);
  ellipse(0, 25, 20, 20);
  ellipse(displayWidth, 25, 20, 20);

  noFill();
  strokeWeight(6);
  stroke(0);
  rect(map(orientation.x, 0, 360, 0, 640)-50,0,100,50);



}
