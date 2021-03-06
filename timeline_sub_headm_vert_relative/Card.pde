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

class Card {

  PVector location;     // x and y location
  PVector size;         // width and height
  PImage image;         // image object
  ArrayList<Card> child_cards =  new ArrayList<Card>();
  int children;         // number of children
  int parent;           // parent's number

  //currently unused. For future implementations.
  int card_n;           // card number, gets assigned with constructor

  String name;          // name of the card
  //

  public Card(String f, int n)
  {
    card_n = n;
    image = loadImage(f);

    int w = image.width;
    int h = image.height;
    size = new PVector(w, h);
    location = new PVector(0, 0);
    children = 0;
  }

  public void setLocation(int x, int y) {
    location.x = x;
    location.y = y;
  }

  public void drawImage() {
      image(image, location.x, location.y);
  }

  public void addChild(String f, int p, int n) {
    children++;
    child_cards.add(new Card(f, n));
    child_cards.get(n).parent = p;
    println("child added");
  }

  public PVector getSize() {
    return size;
  }

  public void removeChild(int j){
    child_cards.remove(j);
  }
}
