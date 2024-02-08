PImage headshot1, headshot2, headshot3, subject;
PGraphics screen;
PGraphics comp;

float radius = 221;
color col = color(0,255,0);
int scene = 1;

void setup() {
    size(1000,1000);
    frameRate(30);
    screen = createGraphics(1000, 1000);
    comp = createGraphics(1000, 1000);
    subject = loadImage("download2.jpg");
    headshot1 = loadImage("headshot1.jpg");
    headshot2 = loadImage("headshot2.jpg");
    headshot3 = loadImage("headshot3.jpg");
}

void draw () {
    screen.beginDraw();
    screen.background(0);
    if (scene == 1) {
    screen.image(headshot1,0,0,1000,1000);
    } else if (scene == 2) {
    screen.image(headshot2,0,0,1000,1000);
    } else if (scene == 3) {
    screen.image(headshot3,0,0,1000,1000);
    }
    screen.endDraw();

    comp.beginDraw();
    comp.background(subject.pixels[1]);
    if (scene == 1) {
    comp.image(subject,390,260,250,250);
    } else if (scene == 2) {
    comp.image(subject,230,150,420,300);
    } else if (scene == 3) {
    comp.image(subject,330,300,330,330);
    }
    keyOut(col);
    comp.loadPixels();
    comp.endDraw();
    
    image(screen,0,0);
    image(comp,0,0);

}

void keyOut(color key) {
    comp.loadPixels();
    for (int i = 0; i < comp.pixels.length; i++) {
                float a = 255;
                float r = red(comp.pixels[i]);
                float g = green(comp.pixels[i]);
                float b = blue(comp.pixels[i]);
                float difr = Math.abs(red(key)-r);
                float difg = Math.abs(green(key)-g);
                float difb = Math.abs(blue(key)-b);
                float diftotal = difr+difg+difb;
                if (diftotal < radius) {
                    a = 0;
                    r = 0;
                    b = 0;
                    g = 0;
                }
                comp.pixels[i] = color(r,g,b,a); 
    }
    comp.updatePixels();
}

void mousePressed() {
    comp.loadPixels();
    int i = mouseY*width+mouseX;
    float r = red(comp.pixels[i]);
    float g = green(comp.pixels[i]);
    float b = blue(comp.pixels[i]);
    col = color(r,g,b);
}

void mouseWheel(MouseEvent event) {
    radius += event.getCount()*-1;
    println(radius);
}

void keyPressed() {
    if (key == 27) {
        key = 0;
    }
    if (key == '1') {
        scene = 1;
    }
    if (key == '2') {
        scene = 2;
    }
    if (key == '3') {
        scene = 3;
    }
    println(scene);
}