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

