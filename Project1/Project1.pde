SimulationController controller = new SimulationController();
PhysicsBody testing = new PhysicsCircle(15000,0.9f,new PVector(400,400),40.0f);
PhysicsBody testing2 = new PhysicsCircle(1.0f,0.9f,new PVector(200,400),new PhysVector(vecScalarMulti(PVector.random2D(),15.0f)),20.0f);
PhysicsBody testing3 = new PhysicsCircle(100.0f,0.9f,new PVector(600,400),new PhysVector(vecScalarMulti(PVector.random2D(),15.0f)),10.0f);
PhysicsBody testing4 = new PhysicsCircle(10.0f,0.9f,new PVector(300,200),new PhysVector(vecScalarMulti(PVector.random2D(),15.0f)),60.0f);

boolean devmode = false;

void setup() {
    size(800, 800);
    frameRate(60);
    controller.startEmptySim(new PVector(0,0), new PVector(800,800),500);
    controller.addActor(testing);
    controller.addActor(testing2);
    controller.addActor(testing3);
    controller.addActor(testing4);
}

void draw() {
    background(255);
    controller.startDraw();
}

void keyPressed() {
    if (key == CODED) {
        if (keyCode == UP) {
            testing.impulse(new PVector(0,-5));
        }
        if (keyCode == DOWN) {
            testing.impulse(new PVector(0,5));
        }
        if (keyCode == LEFT) {
            testing.impulse(new PVector(-5,0));
        }
        if (keyCode == RIGHT) {
            testing.impulse(new PVector(5,0));
        }

    }
    if (key == 10) {
        if (devmode == false) {
            devmode = true;
        } else {
            devmode = false;
        }
    }
}
PhysicsBody selected;
void mousePressed() {
    selected = controller.objectAtPoint(new PVector(mouseX,mouseY));
}
void mouseReleased() {
    if (selected != null) {
        selected.setGravityMode(true);
        selected = null;
    }
}