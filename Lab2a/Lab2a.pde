//globals
//colors
color p = #FFC0CB;
color r = #8B0000;
color black = #ADD8E6;

//brush size
//also controls blur intensity when the filter is enabled
float brushSize = 1.5;

//filters
boolean invert = false;
boolean blur = false;
boolean erode = false;

//logic toggles
boolean alternate = false;

//Main Buffer
PGraphics mb;

void setup() {
    size(500,500);
    frameRate(8);
    mb = createGraphics(width, height);
}

void draw() {
    //Clearing The Display Buffer
    background(255);

    //Opening The Main Buffer
    mb.beginDraw();

    //Draw Shapes To Main Buffer
    quadrants();

    //Closing The Main Buffer
    mb.endDraw();

    //Display Main Buffer
    image(mb,0,0);

    //Apply Post-Processing
    filters();
}

void quadrants() {
    if(mousePressed == true && mouseButton == LEFT) {
        if (mouseX < 250 && mouseY < 250) {
            generateCircles(brushSize);
        } else if (mouseX > 250 && mouseY < 250) {
            generateRect(brushSize);
        } else {
            generateCapsule(mouseX, mouseY, brushSize);
        } 
    }
}

void filters() {
    if (invert == true) {
        filter(INVERT);
    }
    
    if (blur == true) {
        filter(BLUR, 1*brushSize);
    }
    
    if (erode == true) {
        filter(ERODE);
    }
}

void generateCapsule(int posX, int posY, float multi) {
    mb.fill(black);
    mb.beginShape();
    //Main Vertex 1
    mb.vertex(posX-10*multi, posY-10*multi);
    mb.vertex(posX-8*multi, posY-12*multi);
    mb.vertex(posX-6*multi, posY-13*multi);
    mb.vertex(posX-4*multi, posY-14*multi);
    mb.vertex(posX-2*multi, posY-14.5*multi);
    mb.vertex(posX, posY-15*multi);
    mb.vertex(posX+2*multi, posY-14.5*multi);
    mb.vertex(posX+4*multi, posY-14*multi);
    mb.vertex(posX+6*multi, posY-13*multi);
    mb.vertex(posX+8*multi, posY-12*multi);
    //Main Vertex 2
    mb.vertex(posX+10*multi, posY-10*multi);
    //Main Vertex 3
    mb.vertex(posX+10*multi, posY+10*multi);
    mb.vertex(posX+8*multi, posY+12*multi);
    mb.vertex(posX+6*multi, posY+13*multi);
    mb.vertex(posX+4*multi, posY+14*multi);
    mb.vertex(posX+2*multi, posY+14.5*multi);
    mb.vertex(posX, posY+15*multi);
    mb.vertex(posX-2*multi, posY+14.5*multi);
    mb.vertex(posX-4*multi, posY+14*multi);
    mb.vertex(posX-6*multi, posY+13*multi);
    mb.vertex(posX-8*multi, posY+12*multi);
    //Main Vertex 4
    mb.vertex(posX-10*multi, posY+10*multi);
    mb.endShape(CLOSE);
}

void generateCircles(float multi) {
    PVector pos1 = new PVector(mouseX,mouseY+5*multi);
    PVector pos2 = new PVector(mouseX-5*multi,mouseY-5*multi);
    PVector pos3 = new PVector(mouseX+5*multi,mouseY-5*multi);
    if(!alternate) {
        mb.fill(p);
    }
    if (alternate) {
        mb.fill(#FF0000);
    }
    mb.ellipse(pos1.x, pos1.y, 10*multi, 10*multi);
    if (alternate) {
        mb.fill(#00FF00);
    }
    mb.ellipse(pos2.x, pos2.y, 10*multi, 10*multi);
    if (alternate) {
        mb.fill(#0000FF);
    }
    mb.ellipse(pos3.x, pos3.y, 10*multi, 10*multi);
}

void generateRect(float multi) {
    mb.fill(r);
    float nmulti = multi/2;
    float half = 10*nmulti;
    int limit = 6;
    int neg = 1;
    if (alternate) {
        for (int i=1; i < limit;i++) {
            float pos = ceil(i/2)*(20*nmulti);
            mb.rect(mouseX-half, mouseY-half+(pos*neg), 20*nmulti, 20*nmulti);
            neg *= -1;
        }
    } else {
        for (int i=1; i < limit;i++) {
            float pos = ceil(i/2)*(20*nmulti);
            mb.rect(mouseX-half+(pos*neg), mouseY-half, 20*nmulti, 20*nmulti);
            neg *= -1;
        }
    }
}

void keyPressed() {
    //Clear the buffer on esc press
    if (key == 27) {
        key = 0;
        mb.clear();
    }

    if (key == 32) {
        alternate = true;
    }

    if (key == 's') {
        save("Lab02_Maclean.png");
    }

    if (key == '1') {
        if (invert == true) {
            invert = false;
        } else {
            invert = true;
        }
    }
    if (key == '2') {
        if (blur == true) {
            blur = false;
        } else {
            blur = true;
        }
    }
    if (key == '3') {
        if (erode == true) {
            erode = false;
        } else {
            erode = true;
        }
    }
}

void keyReleased() {
        alternate = false; 
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (brushSize > 0.6 && e == 1.0) {
     brushSize -= e*0.2;
  } else if (brushSize < 5.0 && e == -1.0) {
     brushSize -= e*0.2;
  }
}