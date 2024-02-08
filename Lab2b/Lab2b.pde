PImage ref;
PImage flipX;
PImage flipY;
PImage comp;

void setup() {
    size(1600,1000);
    ref = loadImage("CityCrest.png");
    flipX = mirrorX(ref);
    flipY = mirrorY(ref);
    comp = mirrorX(ref);
}

void draw() {
    background(255);
    //Reference Image
    renderImage(ref, 0, 250, 400, 500);

    //X Flip
    renderImage(flipX, 400, 250, 400, 500);

    //Y Flip
    renderImage(flipY, 800, 250, 400, 500);
    
    //Composite
    renderImage(comp, 1450, 250, 500, 500, 0.5, 90);
}

void renderImage(PImage image, int x, int y, int aspectX, int aspectY, float scale, float rotation) {
    float transformFactor = 1/scale;
    pushMatrix();
    scale(scale);
    translate(x*transformFactor, y*transformFactor);
    rotate(radians(rotation));
    image(image, 0, 0, 400, 500);
    popMatrix();
}
void renderImage(PImage image, int x, int y, int aspectX, int aspectY, float scale) {
    renderImage(image, x, y, aspectX, aspectY, scale, 0);
}
void renderImage(PImage image, int x, int y, int aspectX, int aspectY) {
    renderImage(image, x, y, aspectX, aspectY, 1, 0);
}

PImage mirrorX(PImage source) {
    PImage flipped = source.copy();
    flipped.loadPixels();
    for (int y = source.height-1; y >= 0; y--) {
        for (int x = 0; x < source.width; x++) {
            int opIndex = source.width-x-1;
            flipped.pixels[y*source.width + opIndex] = source.pixels[y*source.width + x];
        }
    }
    flipped.updatePixels();
    return flipped;
}

PImage mirrorY(PImage source) {
    PImage flipped = source.copy();
    flipped.loadPixels();
    int invy = 0;
    for (int y = source.height-1; y >= 0; y--) {
        for (int x = 0; x < source.width; x++) {
            int opIndex = source.width-x-1;
            flipped.pixels[y*source.width + x] = source.pixels[invy*source.width + x];
        }
        invy +=1;
    }
    flipped.updatePixels();
    return flipped;
}