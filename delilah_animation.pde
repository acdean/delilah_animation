// delilah animation

static float INPUT_X = 200;
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
  rect(50, 200, 300, 400);
  image(delilah, 50, 200, delilah.width / 2, delilah.height / 2);

  // SQS
  fill(192, 192, 192);
  rect(400, 250, 200, 100);

  // defrost
  fill(192, 255, 192);
  rect(650, 200, 300, 400);
  image(defrost, 650, 200, defrost.width / 2, defrost.height / 2);

  // route
  stroke(128);
  line(INPUT_X, INPUT_Y, INPUT_X, 700);
  line(INPUT_X, 300, 800, 300);
  line(800, 300, 800, 500);
  line(800, 500, 200, 500);

  line(800, 400, 500, 400);
  line(500, 400, 500, 300);

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
    if (r.lifetime == P1 || r.lifetime == P12) {
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

  //if (requests.size() == 0) {
  //  noLoop();
  //} else {
  //  // debug
  //  println(requests.get(0).lifetime);
  //}
}

// 0              0 = 200, 100 - 0
// #              A = 200, 300 - 1, 20
// A####G####B    B = 800, 300 - 5
// #    #    #    C = 500, 400 - 8
// #    C####D    D = 800, 400 - 6, 10
// #         #    E = 800, 500 - 11
// F#########E    F = 200, 500 - 15
// #              G = 500, 300 - 3, 9 *
// 1              1 = 200, 700 - 16, 23

static float X0 = 200, Y0 = 100, P0 = 0;
static float XA = 200, YA = 300, PA = 100, PA2 = 2000;
static float XB = 800, YB = 300, PB = 500;
static float XC = 500, YC = 400, PC = 800;
static float XD = 800, YD = 400, PD = 600, PD2 = 1000;
static float XE = 800, YE = 500, PE = 1100;
static float XF = 200, YF = 500, PF = 1500;
static float XG = 500, YG = 300, PG = 300, PG2 = 900;
static float X1 = 200, Y1 = 700, P1 = 1600, P12 = 2300;

Route[] routes = {
  new Route(P0, PA, X0, Y0, XA, YA),    // 0 - A
  new Route(PA, PG, XA, YA, XG, YG),    // A - G
  new Route(PG, PB, XG, YG, XB, YB),    // G - B
  new Route(PB, PD, XB, YB, XD, YD),    // B - D
  new Route(PD, PC, XD, YD, XC, YC),    // D - C
  new Route(PC, PG2, XC, YC, XG, YG),   // C - G
  new Route(PD2, PE, XD, YD, XE, YE),   // D - E
  new Route(PE, PF, XE, YE, XF, YF),    // E - F
  new Route(PF, P1, XF, YF, X1, Y1),    // F - 1
  // this next one is disjoint
  new Route(PA2, P12, XA, YA, X1, Y1),  // A - 1
};

class Request {
  static final float MAX_SPEED = 0.5;

  float x, y;
  boolean frozen = true;
  float lifetime;
//  float rx, ry;
//  float dx, dy;
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
 //   rx = random(TWO_PI);
 //   ry = random(TWO_PI);
 //   dx = random(-MAX_SPEED, MAX_SPEED);
 //   dy = random(-MAX_SPEED, MAX_SPEED);
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
    if (lifetime > 100 && lifetime <= 900 ) {
      if (random(1000) < 1) {
        frozen = false;
      }
    }

    // looping logic
    // If at A and unfrozen then towards 1
    if (lifetime == PA && !frozen) {
      lifetime = PA2;
    }
    // If at D and unfrozen move towards E
    if (lifetime == PD && !frozen) {
      lifetime = PD2;
    }
    // If at G then loop
    if (lifetime == PG2) {
      lifetime = PG;
    }
  }

  void draw() {
    PImage img;
//    rx += dx;
//    ry += dy;
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
  
  Route(float min, float max, float x0, float y0, float x1, float y1) {
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