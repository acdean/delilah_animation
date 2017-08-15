// delilah animation

static float INPUT_X = 300;
static float INPUT_Y = 100;
PShape shape = null;

ArrayList<Request> requests = new ArrayList<Request>();

void setup() {
  size(1000, 800, P3D);
}

void draw() {
  background(255);
  stroke(0);
  strokeWeight(5);

  // delilah
  line(INPUT_X, INPUT_Y, INPUT_X, 200);
  fill(255, 192, 192);
  rect(100, 200, 400, 200);
  rect(100, 400, 400, 200);
  line(500, 300, 600, 300);

  // defrost queue
  fill(192, 255, 192);
  rect(600, 200, 200, 400);
  line(800, 300, 900, 300);
  line(900, 300, 900, 100);
  line(900, 100, 700, 100);
  line(700, 100, 700, 200);

  line(600, 500, 500, 500);

  line(INPUT_X, 600, INPUT_X, 700);

  strokeWeight(2);
  for (Request request : requests) {
    request.move();
    request.draw();
  }

  // delete the dead nodes
  println("Requests: " + requests.size());
  for (int i = requests.size() - 1 ; i >= 0 ; i--) {
    Request r = requests.get(i);
    if (r.lifetime > 1100) {
      requests.remove(i);
    }
  }

  if (frameCount < 3000 && frameCount % 30 == 1) {
    requests.add(new Request(0));
  }

  if (requests.size() == 0) {
    noLoop();
  }
}

static float MAX_SPEED = .03;

class Request {
  float x, y;
  boolean frozen = true;
  int lifetime;
  float rx, ry;
  float dx, dy;

  Request(int i) {
    init();
    lifetime = i;
  }

  void init() {
    frozen = true;
    x = INPUT_X;
    y = INPUT_Y;
    rx = random(TWO_PI);
    ry = random(TWO_PI);
    dx = random(-MAX_SPEED, MAX_SPEED);
    dy = random(-MAX_SPEED, MAX_SPEED);
    lifetime = 0;
  }

  // jiggery pokery here
  void move() {
    lifetime++;
    // in
    if (lifetime > 0 && lifetime <= 100) {
      x = INPUT_X;
      y = map(lifetime, 0, 100, INPUT_Y, 300);
    }
    // to defrost
    if (lifetime > 100 && lifetime <= 400 ) {
      x = map(lifetime, 100, 400, INPUT_X, 900);
      y = 300;
    }

    // defrost anywhere in the loop
    if (lifetime > 300 && lifetime <= 700 ) {
      if (random(1000) < 1) {
        frozen = false;
      }
    }

    // loop up
    if (lifetime > 400 && lifetime <= 500 ) {
      x = 900;
      y = map(lifetime, 400, 500, 300, 100);
    } // loop left
    if (lifetime > 500 && lifetime <= 600 ) {
      x = map(lifetime, 500, 600, 900, 700);
      y = 100;
    } // loop down
    if (lifetime > 600 && lifetime <= 700 ) {
      x = 700;
      y = map(lifetime, 600, 700, 100, 300);
    }

    // break out of loop if defrosted
    if (lifetime == 700 && frozen == true) {
      lifetime = 300;
    }

    // thawed
    if (lifetime > 700 && lifetime <= 800 ) {
      x = 700;
      y = map(lifetime, 700, 800, 300, 500);
    }
    // across
    if (lifetime > 800 && lifetime <= 1000 ) {
      x = map(lifetime, 800, 1000, 700, INPUT_X);
      y = 500;
    }
    // output
    if (lifetime > 1000 && lifetime <= 1100 ) {
      x = INPUT_X;
      y = map(lifetime, 1000, 1100, 500, 700);
    }
  }

  void draw() {
    rx += dx;
    ry += dy;
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
  }
}