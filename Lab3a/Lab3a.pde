PImage source, iRed, iGreen, iBlue;

PGraphics preFilter;
PGraphics mb;

PFont font;
final float norm = 150/255;
PVector v;

boolean invert = false;
boolean overload = false;
boolean underload = false;
boolean pop = false;

color um = color(0,0,0);
float rum = color(255,0,0);
float gum = color(0,255,0);
float bum = color(0,0,255);

void setup() {
    frameRate(30);
    size(1400,800);
    mb = createGraphics(1400,800);
    preFilter = createGraphics(1400,800);
    font = createFont("Arial", 11, true);
    v = new PVector(350, 500);
    source = loadImage("dreadnought.png");
    iRed = createImage(source.width, source.height, RGB);
    iGreen = createImage(source.width, source.height, RGB);
    iBlue = createImage(source.width, source.height, RGB);
    for (int i = 0; i < source.pixels.length; i++) {
        iRed.pixels[i] = color(red(source.pixels[i]),0,0); 
        iGreen.pixels[i] = color(0, green(source.pixels[i]),0); 
        iBlue.pixels[i] = color(0,0,blue(source.pixels[i])); 
    }
}

void draw() {
    background(200);
    mb.beginDraw();
    //sampling the color under the mouse
    mb.loadPixels();
    um = mb.pixels[mouseY*width+mouseX];
    rum = red(um);
    gum = green(um);
    bum = blue(um);
    mb.background(200);
    
    //Bar Graph
    mb.fill(0);
    mb.textFont(font, 11);
    mb.text(rum, 30,20);
    mb.text(gum, 90,20);
    mb.text(bum, 150,20);

    mb.fill(255, 0, 0);
    float dif = Math.round(rum*norm);
    mb.rect(30, 30+dif, 50, rum);
    mb.fill(0, 255, 0);
    dif = Math.round(gum*norm);
    mb.rect(90, 30+dif, 50, gum);
    mb.fill(0, 0, 255);
    dif = Math.round(bum*norm);
    mb.rect(150, 30+dif, 50, bum);

    //4 Images
    mb.image(source, 0, 300, v.x, v.y);
    mb.image(iRed, 350, 300, v.x, v.y);
    mb.image(iGreen, 700, 300, v.x, v.y);
    mb.image(iBlue, 1050, 300, v.x, v.y);
    
    preFilter.beginDraw();
    preFilter.loadPixels();
    mb.loadPixels();
    preFilter.pixels = mb.pixels;
    preFilter.updatePixels();
    preFilter.endDraw();
    mb.beginDraw();
    //filter application
    filters();

    //Color Sample
    preFilter.loadPixels();
    um = mb.pixels[mouseY*width+mouseX];
    rum = red(um);
    gum = green(um);
    bum = blue(um);
    mb.fill(0);
    mb.textFont(font, 24);
    mb.text("Color Sample", 220+60,20);
    mb.fill(rum,gum,bum);
    mb.rect(220, 30, 255, 255);

    mb.endDraw();
    
    image(mb,0,0);
}
void filters() {
    if (invert == true) {
        mb.loadPixels();
            for (int i = 0; i < mb.pixels.length; i++) {
                mb.pixels[i] = color(255-red(mb.pixels[i]),255-green(mb.pixels[i]),255-blue(mb.pixels[i])); 
            }
        mb.updatePixels(); 
    }
    if (overload == true) {
        mb.loadPixels();
            for (int i = 0; i < mb.pixels.length; i++) {
                mb.pixels[i] = color(red(mb.pixels[i])+50,green(mb.pixels[i])+50,blue(mb.pixels[i])+50); 
            }
        mb.updatePixels(); 
    }
    if (underload == true) {
        mb.loadPixels();
            for (int i = 0; i < mb.pixels.length; i++) {
                mb.pixels[i] = color(red(mb.pixels[i])-50,green(mb.pixels[i])-50,blue(mb.pixels[i])-50); 
            }
        mb.updatePixels(); 
    }
    if (pop == true) {
        mb.loadPixels();
            for (int i = 0; i < mb.pixels.length; i++) {
                float r = red(mb.pixels[i]);
                float g = green(mb.pixels[i]);
                float b = blue(mb.pixels[i]);

                if (r > 150) {
                    r = 255;
                } else if (r < 100) {
                    r = 0;
                }
                if (g > 150) {
                    g = 255;
                } else if (g < 100) {
                    g = 0;
                }
                if (b > 150) {
                    b = 255;
                } else if (b < 100) {
                    b = 0;
                }
                mb.pixels[i] = color(r,g,b); 
            }
        mb.updatePixels(); 
    }
}
void keyPressed() {
    if (key == 'i') {
        if (invert == true) {
            invert = false;
        } else {
            invert = true;
        }
    }
    if (key == 'o') {
        if (overload == true) {
            overload = false;
        } else {
            overload = true;
        }
    }
    if (key == 'u') {
        if (underload == true) {
            underload = false;
        } else {
            underload = true;
        }
    }
    if (key == 'p') {
        if (pop == true) {
            pop = false;
        } else {
            pop = true;
        }
    }
}