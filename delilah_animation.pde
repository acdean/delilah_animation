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
  image(delilah, 100, 200);

  // defrost queue
  fill(192, 255, 192);
  rect(600, 200, 200, 400);
  image(defrost, 600, 200);

  // route
  line(INPUT_X, 300, 900, 300);
  line(900, 300, 900, 100);
  line(900, 100, 700, 100);
  line(700, 100, 700, 500);
  line(700, 500, INPUT_X, 500);

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
    if (frameCount < 3000 || keyPressed) {
      requests.add(new Request(0));
    }
  }

  if (requests.size() == 0) {
    noLoop();
  }
}

class Request {
  float x, y;
  boolean frozen = true;
  int lifetime;
  float rx, ry;
  float dx, dy;
  int index = 0;

  Route[] routes = {
    new Route(0, 100, INPUT_X, INPUT_X, INPUT_Y, 300),    // in
    new Route(100, 400, INPUT_X, 900, 300, 300),          // to defrost
    new Route(400, 500, 900, 900, 300, 100),              // loop up
    new Route(500, 600, 900, 700, 100, 100),              // loop left
    new Route(600, 700, 700, 700, 100, 300),              // loop down
    new Route(700, 800, 700, 700, 300, 500),              // thawed down
    new Route(800, 1000, 700, INPUT_X, 500, 500),         // thawed left
    new Route(1000, 1100, INPUT_X, INPUT_X, 500, 700),    // balham
    // this next one is disjoint
    new Route(2000, 2200, INPUT_X, INPUT_X, 300.0, 700),   // straight through
  };

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
    if (lifetime > 0 && lifetime <= 700 ) {
      if (random(1000) < 1) {
        frozen = false;
      }
    }

    // break out of loop if defrosted
    if (lifetime == 700 && frozen) {
      lifetime = 300;
    }
    // break out of loop if defrosted
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
    image(img, x, y);
    /*
    pushMatrix();
    translate(x, y, 30);
    if (frozen) {
      fill(192, 192, 255); // blue
    } else {
      fill(255, 255, 192);  // grey
    }
    rotateX(rx);
    rotateY(ry);
    box(40);
    popMatrix();
    */
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