// delilah animation
// acd 2017

static float INPUT_X = 200;
static float INPUT_Y = 100;
PShape shape = null;

ArrayList<Request> requests = new ArrayList<Request>();
PImage[] ice = new PImage[10];
PImage[] fire = new PImage[10];
PImage delilah, defrost, unknown, green, bgImg;
PImage tick, cross, sqs;
Check check1, check2;
Queue q1, q2, q3;
Process p1, p2;
boolean pause = false;

void setup() {
  size(1400, 1080, P2D);
  //fullScreen();
  imageMode(CENTER);
  for (int i = 0; i < 10; i++) {
    ice[i] = loadImage("ice" + i + ".png");
    fire[i] = loadImage("fire" + i + ".png");
  }
  unknown = loadImage("unknown.png");
  green = loadImage("green.png");
  delilah = loadImage("delilah.png");
  defrost = loadImage("defrost.png");
  tick = loadImage("tick.png");
  cross = loadImage("cross.png");
  sqs = loadImage("sqs.png");
  bgImg = loadImage("background.png");
  check1 = new Check(XA, YA); // A
  check2 = new Check(XD, YD); // D
  q1 = new Queue(X0, Y0);
  q2 = new Queue(XC, YC);
  q3 = new Queue(X1, Y1);
  p1 = new Process(XB, YB);
  p2 = new Process(XF, YF);
}

void draw() {
  if (pause) {
    return;
  }
  background(255);
  //  background(bgImg);
  stroke(0);
  strokeWeight(5);
  imageMode(CORNER);

  // delilah
  fill(255, 192, 192);
  rect(XA - W - 20, YA - H - 20, XB + W + 20, YF + H + 20);
  image(delilah, XA - W, YA + H, delilah.width / 2, delilah.height / 2);

  // defrost
  fill(192, 255, 192);
  rect(XD - W - 20, YD - H - 20, XE + W + 20, YE + H + 20);
  image(defrost, XD - W, YD + H, defrost.width / 2, defrost.height / 2);

  // route
  stroke(128);
  line(X0, Y0, X1, Y1);
  line(XA, YA, XB, YB);
  line(XC, YC, XD, YD);
  line(XD, YD, XE, YE);
  line(XE, YE, XF, YF);

  imageMode(CENTER);
  strokeWeight(2);
  stroke(0);
  fill(255);

  // diamonds
  check1.draw();
  check2.draw();

  // queues
  q1.draw();
  q2.draw();
  q3.draw();

  // processes
  p1.draw();
  p2.draw();

  for (Request request : requests) {
    request.move();
    request.draw();
  }

  // delete the dead nodes
  //println("Requests: " + requests.size());
  for (int i = requests.size() - 1; i >= 0; i--) {
    Request r = requests.get(i);
    if (r.lifetime == P1 || r.lifetime == P12) {
      requests.remove(i);
    }
  }

  // add a request every n frames for the first 3000 frames
  // or if the key is pressed
  if (frameCount % 30 == 1) {
    if (frameCount < 3000) {
      requests.add(new Request());
    }
  }
}

// 0           0 =  215, 120 - 0
// #           A =  215, 380 - 2, 30
// A##B##C##D  B =  540, 300 - 8
// #        #  C =  860, 380 
// #        #  D = 1180, 380
// F########E  E = 1180, 700 - 15
// #           F =  215, 700 - 21
// 1           1 =  215, 960 - 16, 34

static int X0 = 215, Y0 = 120, P0 = 0;
static int XA = 215, YA = 380, PA = 100, PA2 = 2000;
static int XB = 540, YB = 380, PB = 200;
static int XC = 860, YC = 380, PC = 300, PC2 = 500;
static int XD = 1180, YD = 380, PD = 400, PD2 = 600;
static int XE = 1180, YE = 700, PE = 800;
static int XF = 215, YF = 700, PF = 1100, PF2 = 2200;
static int X1 = 215, Y1 = 960, P1 = 1200, P12 = 2300;

Route[] routes = {
  new Route(P0, PA, X0, Y0, XA, YA), // 0 - A
  new Route(PA, PB, XA, YA, XB, YB), // A - B
  new Route(PB, PC, XB, YB, XC, YC, true), // B - C
  new Route(PC, PD, XC, YC, XD, YD), // C - D
  new Route(PD, PC2, XD, YD, XC, YC, true), // D - C2
  new Route(PD2, PE, XD, YD, XE, YE), // D2 - E
  new Route(PE, PF, XE, YE, XF, YF), // E - F
  new Route(PF, P1, XF, YF, X1, Y1), // F - 1
  // this next one is disjoint
  new Route(PA2, P12, XA, YA, X1, Y1), // A - 1
};

class Request {
  //  static final float MAX_SPEED = 0.5;

  float x, y;
  boolean frozen = true;
  float lifetime;
  int index = 0;
  PImage img;

  Request() {
    init();
    lifetime = 0;
    index = (int)random(10);
    img = unknown;
  }

  Request(boolean frozen) {
    this();
    this.frozen = frozen;
  }

  void init() {
    frozen = true;
    if (random(100) < 2) {
      frozen = false;
    }
    x = INPUT_X;
    y = INPUT_Y;
    lifetime = 0;
  }

  void move() {
    lifetime += 1;

    // jiggery pokery here
    for (Route route : routes) {
      PVector p = route.calc(lifetime);
      if (p != null) {
        x = p.x;
        y = p.y;
      }
    }

    // defrost anywhere in the loop
    if (lifetime > PB && lifetime <= PC2 ) {
      if (random(1000) < 1) {
        frozen = false;
        img = fire[index];
      }
    }

    // looping logic
    // If at A and unfrozen then towards 1
    if (lifetime == PA) {
      check1.on(frozen);
      if (!frozen) {
        lifetime = PA2;
        img = fire[index];
      } else {
        img = ice[index];
      }
    }
    // If at D and unfrozen move towards E
    if (lifetime == PD) {
      check2.on(frozen);
      if (!frozen) {
        lifetime = PD2;
      }
    }
    // If at C2 then loop
    if (lifetime == PC2) {
      lifetime = PC;
    }
    if (lifetime == PF || lifetime == PF2) {
      img = green;
    }
  }

  void draw() {
    pushMatrix();
    translate(x, y);
    rotate(5 * radians(sin(lifetime / 8.0)));
    image(img, 0, 0, img.width, img.height);
    popMatrix();
  }
}

// these are the routes, now done as data
class Route {
  final float LOOP_HEIGHT = 300;

  float min, max;
  int x0, x1, y0, y1;
  PVector p = new PVector();
  boolean hyp;

  Route(float min, float max, int x0, int y0, int x1, int y1) {
    this(min, max, x0, y0, x1, y1, false);
  }
  Route(float min, float max, int x0, int y0, int x1, int y1, boolean hyp) {
    this.min = min;
    this.max = max;
    this.x0 = x0;
    this.x1 = x1;
    this.y0 = y0;
    this.y1 = y1;
    this.hyp = hyp;
  }

  // if the count is within the min max limits then map count to position
  PVector calc(float count) {
    if (count > min && count <= max) {
      if (hyp) {
        // hyperbolic (actually, sin)
        float angle = map(count, min, max, 0, PI);
        p.set(
          map(count, min, max, x0, x1), 
          map(count, min, max, y0, y1) - LOOP_HEIGHT * sin(angle)
          );
      } else {
        // linear
        p.set(
          map(count, min, max, x0, x1), 
          map(count, min, max, y0, y1)
          );
      }
      return p;
    } else {
      return null;
    }
  }
}

void keyReleased() {
  if (key == ' ') {
    // more
    requests.add(new Request());
  } else if (key == 'f') {
    // add a frozen one
    requests.add(new Request(true));
  } else if (key == 'u') {
    // unfrozen one
    requests.add(new Request(false));
  } else {
    // (un)pause
    pause = !pause;
  }
}

// size of shapes
final int W = 150;
final int H = 75;

class Shape {
  float x, y;
  Shape(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

interface Draw {
  void draw();
}

// the two checkpoints flash up their decisions
class Check extends Shape implements Draw {

  final int LIFETIME = 15;
  int counter;
  PImage img;

  Check(int x, int y) {
    super(x, y);
  }

  void on(boolean frozen) {
    if (frozen) {
      img = cross;
    } else {
      img = tick;
    }
    counter = LIFETIME;
  }

  void draw() {
    // diamond
    beginShape();
    vertex(x, y - H); // up
    vertex(x + W, y);     // right
    vertex(x, y + H);     // down
    vertex(x - W, y);     // left
    endShape(CLOSE);
    // icon
    if (counter > 0) {
      counter--;
      image(img, x + 100, y - 75, img.width / 3, img.height / 3);
    }
  }
}

class Process extends Shape {
  PImage img;
  Process(int x, int y) {
    super(x, y);
  }
  void draw() {
    // rectangle
    rectMode(CORNERS);
    rect(x - W * .75, y - H * .75, x + W * .75, y + H * .75);
  }
}

class Queue extends Shape {
  Queue(float x, float y) {
    super(x, y);
  }
  void draw() {
    image(sqs, x, y);
  }
}