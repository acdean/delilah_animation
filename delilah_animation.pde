// delilah animation

static float INPUT_X = 200;
static float INPUT_Y = 100;
PShape shape = null;

ArrayList<Request> requests = new ArrayList<Request>();
PImage[] ice = new PImage[10];
PImage[] fire = new PImage[10];
PImage delilah, defrost, unknown, green;
PImage tick, cross, sqs;
Check check1, check2;
boolean pause = false;

void setup() {
  size(1000, 800, P2D);
  imageMode(CENTER);
  for (int i = 0 ; i < 10 ; i++) {
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
  check1 = new Check(150, 300); // A = 200, 300
  check2 = new Check(850, 300); // D = 800, 300
}

void draw() {
  if (pause) {
    return;
  }
  background(255);
  stroke(0);
  strokeWeight(5);
  imageMode(CORNER);

  // delilah
  fill(255, 192, 192);
  rect(50, 200, 300, 400);
  image(delilah, 50, 200, delilah.width / 2, delilah.height / 2);

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

  //line(800, 400, 500, 400);
  //line(500, 400, 500, 300);

  // SQS
  imageMode(CENTER);
  image(sqs, X0, Y0);  // input
  image(sqs, XG, YG);  // defrost
  image(sqs, X1, Y1);  // output

  strokeWeight(2);
  for (Request request : requests) {
    request.move();
    request.draw();
  }
  
  check1.draw();
  check2.draw();

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
    if (frameCount < 3000) {
      requests.add(new Request());
    }
  }
}

// 0          0 = 200, 100 - 0
// #          A = 200, 300 - 2, 30
// A##G##B    B = 800, 300 - 8
// #     #    
// #     #    
// F#####E    E = 800, 500 - 15
// #          F = 200, 500 - 21
// 1          G = 500, 300 - 3, 13 *
//            1 = 200, 700 - 16, 34

static float X0 = 200, Y0 = 100, P0 = 0;
static float XA = 200, YA = 300, PA = 200, PA2 = 3000;
static float XG = 500, YG = 300, PG = 500, PG2 = 1100;
static float XB = 800, YB = 300, PB = 800, PB2 = 1200;
static float XE = 800, YE = 500, PE = 1300;
static float XF = 200, YF = 500, PF = 1900, PF2 = 3200;
static float X1 = 200, Y1 = 700, P1 = 2100, P12 = 3400;

Route[] routes = {
  new Route(P0, PA, X0, Y0, XA, YA),        // 0 - A
  new Route(PA, PG, XA, YA, XG, YG, true),  // A - G  // throw to g
  new Route(PG, PB, XG, YG, XB, YB),        // G - B
  new Route(PB, PG2, XB, YB, XG, YG, true), // B - G  // throw to g
  new Route(PB2, PE, XB, YB, XE, YE),       // B - E
  new Route(PE, PF, XE, YE, XF, YF),        // E - F
  new Route(PF, P1, XF, YF, X1, Y1),        // F - 1
  // this next one is disjoint
  new Route(PA2, P12, XA, YA, X1, Y1),  // A - 1
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
    lifetime += 2;
    
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
    // If at B and unfrozen move towards E
    if (lifetime == PB) {
      check2.on(frozen);
      if (!frozen) {
        lifetime = PB2;
      }
    }
    // If at G then loop
    if (lifetime == PG2) {
      lifetime = PG;
    }
    if (lifetime == PF || lifetime == PF2) {
      img = green;
    }
  }
  
  void draw() {
    pushMatrix();
    translate(x, y);
    rotate(5 * radians(sin(lifetime / 8.0)));
    image(img, 0, 0, img.width * .75, img.height * .75);
    popMatrix();
  }
}

// these are the routes, now done as data
class Route {
  final float LOOP_HEIGHT = 300;

  float min, max, x0, x1, y0, y1;
  PVector p = new PVector();
  boolean hyp;
  
  Route(float min, float max, float x0, float y0, float x1, float y1) {
    this(min, max, x0, y0, x1, y1, false);
  }
  Route(float min, float max, float x0, float y0, float x1, float y1, boolean hyp) {
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

// the two checkpoints flash up their decisions
class Check {
  
  final int LIFETIME = 15;
  int counter;
  PImage img;
  int x, y;
  
  Check(int x, int y) {
    this.x = x;
    this.y = y;
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
    if (counter > 0) {
      counter--;
      image(img, x, y, img.width / 3, img.height / 3);
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