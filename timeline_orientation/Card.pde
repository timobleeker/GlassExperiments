class Card {

  PVector location;     // x and y location
  PVector size;         // width and height
  PImage image;         // image object
  
  //currently unused. For future implementations.
  int card_n;           // card number, gets assigned with constructor
  int children;         // number of children  
  int parent;           // parent's number
  String name;          // name of the card
  //

  public Card(String i, int n)
  {
    card_n = n;
    image = loadImage(i);

    int w = image.width;
    int h = image.height;
    size = new PVector(w, h);
    location = new PVector(0, 0);
  }

  public void setLocation(int x, int y) {
    location.x = x;
    location.y = y;
  } 

  public void drawImage() {
    image(image, location.x, location.y);
  }
  
  public PVector getSize(){
   return size; 
  }
}

