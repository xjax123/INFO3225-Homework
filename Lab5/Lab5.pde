//Globals (dont touch these)
PGraphics canvas;

//Controllers (change these to change the effect)
int depth = 6;
int startingSize = 16;
color startingColor = color(255,255,255,255); //White
color backgroundColor = color(0,0,0,255); //Black

float growthMulti = 1;
int splitFactor = 40;
int alphaDecay = 0;
int redDecay = 0;
int greenDecay = 0;
int blueDecay = 0;

void setup() {
    size(800,800);
    background(backgroundColor);
    canvas = createGraphics(800, 800);
    smooth();
    Circle c = new Circle(400,400,5,red(startingColor),green(startingColor),blue(startingColor),alpha(startingColor));
    canvas.beginDraw();
    canvas.noStroke();
    fractal(c,depth);
    canvas.endDraw();
}

void draw() {
    background(backgroundColor);
    image(canvas,0,0);
}

void fractal(Circle c, int N) {
    c.draw();
    if (N == 0) {
        return;
    } else {
        Circle c1 = new Circle(c.x-splitFactor, c.y-splitFactor, c.r*growthMulti, c.red-redDecay, c.green-greenDecay, c.blue-blueDecay, c.alpha-alphaDecay);
        Circle c2 = new Circle(c.x+splitFactor, c.y-splitFactor, c.r*growthMulti, c.red-redDecay, c.green-greenDecay, c.blue-blueDecay, c.alpha-alphaDecay);
        Circle c3 = new Circle(c.x+splitFactor, c.y+splitFactor, c.r*growthMulti, c.red-redDecay, c.green-greenDecay, c.blue-blueDecay, c.alpha-alphaDecay);
        Circle c4 = new Circle(c.x-splitFactor, c.y+splitFactor, c.r*growthMulti, c.red-redDecay, c.green-greenDecay, c.blue-blueDecay, c.alpha-alphaDecay);
        fractal(c1, N-1);
        fractal(c2, N-1);
        fractal(c3, N-1);
        fractal(c4, N-1);
    }
}

class Circle {
    public float r,x,y,col;
    public float red,green,blue,alpha;
    
    Circle(float x, float y, float r, float red, float green, float blue, float alpha) {
        this.x = x;
        this.y = y;
        this.r = r;
        this.red = red;
        this.green = green;
        this.blue = blue;
        this.alpha = alpha;
    }

    public void draw() {
        canvas.fill(color(red,green,blue,alpha));
        canvas.circle(x, y, r);
    }

}
