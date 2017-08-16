// delilah animation

static float INPUT_X = 300;
static float INPUT_Y = 100;
PShape shape = null;

ArrayList<Request> requests = new ArrayList<Request>();
PImage[] ice = new PImage[10];
PImage[] fire = new PImage[10];
PImage delilah, defrost, question;

void setup() {
  size(1000, 800, P2D);
  imageMode(CENTER);
  for (int i = 0 ; i < 10 ; i++) {
    ice[i] = loadImage("ice" + i + ".png");
    fire[i] = loadImage("fire" + i + ".png");
  }
  question = loadImage("question.png");
  delilah = loadImage("delilah.png");
  defrost = loadImage("defrost.png");
}

void draw() {
  background(255);
  stroke(0);
  strokeWeight(5);
  imageMode(CORNER);

  // delilah
  fill(255, 192, 192);
  rect(100, 200, 400, 400);
  image(delilah, 100, 200, delilah.width / 2, delilah.height / 2);

  // defrost queue
  fill(192, 192, 192);
  rect(600, 250, 200, 100);
  fill(192, 255, 192);
  rect(600, 400, 200, 200);
  image(defrost, 600, 400, defrost.width / 2, defrost.height / 2);

  // route
  stroke(128);
  line(INPUT_X, 300, 900, 300);
  line(700, 300, 700, 500);
  line(900, 500, 900, 300);
  line(900, 500, INPUT_X, 500);
  line(INPUT_X, INPUT_Y, INPUT_X, 700);

  strokeWeight(2);
  imageMode(CENTER);
  for (Request request : requests) {
    request.move();
    request.draw();
  }

  // delete the dead nodes
  //println("Requests: " + requests.size());
  for (int i = requests.size() - 1 ; i >= 0 ; i--) {
    Request r = requests.get(i);
    if (r.lifetime == 1100 || r.lifetime == 2200) {
      requests.remove(i);
    }
  }

  // add a request every 30 frames for the first 3000 frames
  // or if the key is pressed
  if (frameCount % 30 == 1) {
//    if (frameCount < 3000 || keyPressed) {
    if (frameCount < 300 || keyPressed) {
      requests.add(new Request(0));
    }
  }

  if (requests.size() == 0) {
    noLoop();
  }
}

Route[] routes = {
  new Route(0, 100, INPUT_X, INPUT_X, INPUT_Y, 300),    // in
  new Route(100, 300, INPUT_X, 700, 300, 300),          // to defrost (300 is defrost point)
  new Route(300, 400, 700, 700, 300, 500),              // out of defrost
  new Route(400, 500, 700, 900, 500, 500),              // loop right
  new Route(500, 600, 900, 900, 500, 300),              // loop up
  new Route(600, 700, 900, 700, 300, 300),              // loop left
  new Route(700, 800, 700, 700, 300, 500),              // down again
  new Route(800, 1000, 700, 300, 500, 500),             // thawed left
  new Route(1000, 1100, INPUT_X, INPUT_X, 500, 700),    // balham
  // this next one is disjoint
  new Route(2000, 2200, INPUT_X, INPUT_X, 300, 700),    // straight through
};

class Request {
  static final float MAX_SPEED = 0.5;

  float x, y;
  boolean frozen = true;
  int lifetime;
  float rx, ry;
  float dx, dy;
  int index = 0;

  Request(int i) {
    init();
    lifetime = i;
    index = (int)random(10);
  }

  void init() {
    frozen = true;
    if (random(100) < 2) {
      frozen = false;
    }
    x = INPUT_X;
    y = INPUT_Y;
    rx = random(TWO_PI);
    ry = random(TWO_PI);
    dx = random(-MAX_SPEED, MAX_SPEED);
    dy = random(-MAX_SPEED, MAX_SPEED);
    lifetime = 0;
  }

  void move() {
    lifetime++;
    
    // jiggery pokery here
    for (Route route : routes) {
      PVector p = route.calc(lifetime);
      if (p != null) {
        x = p.x;
        y = p.y;
      }
    }
    
    // defrost anywhere in the loop
    if (lifetime > 100 && lifetime <= 700 ) {
      if (random(1000) < 1) {
        frozen = false;
      }
    }

    // looping logic
    if (lifetime == 400 && !frozen) {
      lifetime = 800;
    }
    if (lifetime == 800 && frozen) {
      lifetime = 400;
    }
    if (lifetime == 100 && !frozen) {
      lifetime = 2000;
    }
  }

  void draw() {
    PImage img;
    rx += dx;
    ry += dy;
    if (frozen) {
      img = ice[index];
    } else {
      img = fire[index];
    }
    image(img, x, y, img.width * .75, img.height * .75);
  }
}

// these are the routes, now done as data
class Route {
  float min, max, x0, x1, y0, y1;
  PVector p = new PVector();
  
  Route(float min, float max, float x0, float x1, float y0, float y1) {
    this.min = min;
    this.max = max;
    this.x0 = x0;
    this.x1 = x1;
    this.y0 = y0;
    this.y1 = y1;
  }
  
  // if the count is within the min max limits then map count to position
  PVector calc(float count) {
    if (count > min && count <= max) {
      p.set(
        map(count, min, max, x0, x1),
        map(count, min, max, y0, y1)
      );
      return p;
    } else {
      return null;
    }
  }
}