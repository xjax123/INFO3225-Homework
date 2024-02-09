import java.util.*;

PGraphics background, foreground, subject;
Thread bgDraw, fgDraw, subDraw;
StarMap starmap;
DynScene scene;

void setup() {
    size(1000, 900);
    frameRate(8);
    starmap = new StarMap();
    scene = new DynScene();
    background = createGraphics(1000, 900);
    foreground = createGraphics(1000, 900);
    subject = createGraphics(1000, 900);
    bgDraw = new Thread(() -> {prepareBackground();});
    fgDraw = new Thread(() -> {prepareForeground();});
    subDraw = new Thread(() -> {prepareSubject();});
    bgDraw.start();
    fgDraw.start();
    subDraw.start();
}

void draw() {
    background(0);

    animateObjects();

    image(background, 0, 0);
    image(foreground, 0, 0);
    image(subject, 0, 0);
}

void prepareBackground() {
    background.beginDraw();
    background.background(30);

    //setting up values
    float freq1, freq2;
    float[] map = new float[background.width*background.height];
    float mapmax = 0;
    float mapmin = 1;
    freq1 = 0.003;
    freq2 = 0.01;


    //implementation of 2-layer perlin noise
    //loosely based on this article: https://rtouti.github.io/graphics/perlin-noise-algorith
    background.loadPixels();
    for(int y = 0; y < background.height; y++) {
        //precomputing all y values to help save on render time
        float prey1 = y*freq1;
        float prey2 = y*freq2;
        int backy = y*background.width;
        for (int x = 0; x < background.width; x++) {
            //generating base noise values
            float n = noise(x*freq1, prey1,20);
            float d = noise(x*freq2, prey2,30);
            
            //compound value (weighted towards lower detail noise) to give texture
            float comp = n*0.7+d*0.3;
            comp += 1.0;
            comp *= 0.5; //avoiding division

            map[backy+x] = comp; //adding raw values to a map for later reference
            if (comp > mapmax) {
                mapmax = comp;
            }
            if (comp < mapmin) {
                mapmin = comp;
            }
            int c = (int) Math.round(comp*40);
            
            //generating a blue-dominant hue
            background.pixels[backy+x] = color(c-10,c-10,c);
        }
    }
    background.updatePixels();

    //generating stars from the map established earlier
    int minGap = 4; //min number of pixels between each star.
    int starMax = 6; //max size of stars
    int starMin = 2; //min size of stars
    float starWeight = 2; //influences the number of stars generated, higher is more.
    for(int y = 0; y < background.height; y++) {
        int backy = y*background.width;
        for (int x = 0; x < background.width; x++) {
            //exponential random function so stars are clustered around light points.
            float val = (float) Math.log(Math.random())/((float) -normalize(map[backy+x],mapmin,mapmax)*(starWeight*0.01));
            if (val < 0.1) {
                //testing if the generated star is too close to an existing one (as defined by minGap)
                //this is pretty slow, because it reduces this loop to O(N^3) but other approaches like GLSL compute shaders would be a bit too time intensive for me to work on right now.
                UStar nearest = starmap.nearestNeighbor(x,y);
                float dist = distance(x,nearest.posX(),y,nearest.posY());
                if (dist > minGap) {
                    UStar star;
                    int colOff = (int) Math.round(Math.random() * (55 - 5) + 5);
                    color col = color(200,200,200+colOff);
                    int size = (int) Math.round(Math.random() * (starMax - starMin) + starMin);
                    star = new UStar(x,y,size,col);
                    starmap.add(star);
                }
            }
        }
    }
    background.filter(BLUR, 1);
    background.endDraw();
    PGraphics stars;
    stars = createGraphics(background.width, background.height);
    stars.beginDraw();
    for (int i = 0; i < starmap.size(); i++) {
        UStar star = starmap.retrieve(i);
        stars.fill(star.col());
        stars.circle(star.posX(), star.posY(), star.radius());
    }
    stars.filter(BLUR, 1.2);
    stars.endDraw();

    background.beginDraw();
    background.image(stars,0,0);
    background.endDraw();
}

void prepareForeground() {
    foreground.beginDraw();

    float freq1, freq2;
    freq1 = 0.01;
    freq2 = 0.005;

    //Define the ground area
    foreground.fill(100, 119, 192);
    foreground.beginShape();
    foreground.vertex(0, 570);
    foreground.vertex(1000, 520);
    foreground.vertex(1000, 900);
    foreground.vertex(0, 900);
    foreground.endShape(CLOSE);

    //more perlin noise for splatter
    /*
    * this function causes some strange behavior with the star generation, I think it has to do with simultaneous sampling of the noise() function since it wasnt set up for asyn operation.
    * consider implementing a custom perlin noise sampler to sidestep this issue.
    * 
    * Presently, suspending the background thread until the splatter is drawn sidesteps the issue (the reverse did not work) however this somewhat defeats the point of async drawing,
    * even if it still retains some advantages.
    */
    bgDraw.suspend();
    int itterations = 4;
    for (int i = 0; i < itterations; i++) {
        foreground.loadPixels();
            int redoff = (int) Math.round(Math.random()*40);
            int greenoff = (int) Math.round(Math.random()*40);
            int blueoff = (int) Math.round(Math.random()*20);
        for(int y = 0; y < foreground.height; y++) {
            //precomputing all y values to help save on render time
            float prey1 = y*freq1;
            float prey2 = y*freq2;
            int backy = y*foreground.width;
            for (int x = 0; x < foreground.width; x++) {
                color col = foreground.pixels[backy+x];
                float alph = alpha(foreground.pixels[backy+x]);
                float adjAlpha = normalize(75,0,255);
                if (alph == 0) {
                    continue;
                }
                //generating base noise values
                float n1 = noise(x*freq1, prey1,i);
                float n2 = noise(x*freq2, prey2,i+itterations);
                float n = (n1*0.6+n2*0.4);
                n += 1;
                n *= 0.5;
                //clamping and normalizing to try and get a roughly "splatter like" pattern
                n = shunt(n, 0.75, 1.0);
                n = normalize(n, 0.75, 0.76);
                int c = (int) Math.round(n*255);
                color ncol = color(c-30,c-30,c);
                color fcol = lerpColor(col, ncol, adjAlpha);
                if (c == 0) {
                    fcol = col;
                }
                foreground.pixels[backy+x] = color(red(fcol)-redoff,green(fcol)-greenoff,blue(fcol)-blueoff,alph);
            }
        }
        foreground.updatePixels();
    }
    foreground.filter(BLUR, 1.5);
    foreground.endDraw();
    bgDraw.resume();
}

void prepareSubject() {
    //prepare static objects
    
    //prepare dynamic objects
}

void animateObjects() {

}

public float normalize(float val, float min, float max) {
    return (val - min)/(max - min);
}

public float distance(int x1, int x2, int y1, int y2) {
    int xd = x1 - x2;
    int yd = y1 - y2;
    float dist = (float) Math.sqrt(xd*xd + yd*yd);
    return dist;
}

public float clamp(float val, float min, float max) {
    float temp;
    if (val < min) {
        temp = min;
    } else if (val > max) {
        temp = max;
    } else {
        temp = val;
    }
    return temp;
}

public float shunt(float val, float min, float max) {
    float temp;
    if (val > min) {
        temp = max;
    } else {
        temp = min;
    }
    return temp;
}

class UStar {
    PVector pos;
    int radius;
    color col;
    
    public UStar(int x, int y, int r, color col) {
        this.pos = new PVector(x,y);
        this.radius = r;
        this.col = col;
    }
    public UStar() {
        this.pos = new PVector(0,0);
        this.radius = 0;
        this.col = color(0,0,0);
    }

    public PVector pos() {
        return pos;
    }

    public int posX() {
        return (int) pos.x;
    }

    public int posY() {
        return (int) pos.y;
    }

    public int radius() {
        return radius;
    }

    public color col() {
        return col;
    }
}

class StarMap {
    private List<UStar> starMap;

    public StarMap() {
        starMap = new ArrayList<UStar>();
    }

    public UStar nearestNeighbor(int x, int y) {
        float closestDist = 99999999; //arbitrarily high, so its initialized, but always overwritten
        UStar neighbor = new UStar();
        for (int i = 0; i < starMap.size(); i++) {
            UStar ref = starMap.get(i);
            float dist = distance(x,ref.posX(),y,ref.posY());
            if (dist < closestDist) {
                closestDist = dist;
                neighbor = ref;
            }
        }
        return neighbor;
    }

    public void add(UStar star) {
        starMap.add(star);
    }

    public int size() {
        return starMap.size();
    }

    public UStar retrieve(int index) {
        return starMap.get(index);
    }
}

class DynObject {
    private PVector pos;
    private List<PVector> verts;
    private color fill;

    public DynObject() {
        this.pos = new PVector(0,0);
        this.verts = new ArrayList<PVector>();
        this.fill = color(0,0,0); 
    }

    public DynObject(PVector pos, List<PVector> vertexes, color fill) {
        this.pos = pos;
        this.verts = vertexes;
        this.fill = fill;
    }

    //render to screen
    public void render() {

    }

    //render to a specific buffer
    public void render(PGraphics buffer) {
        
    }

    //absolute movement
    public void move(PVector v) {

    }

    //relative movement
    public void nudge(PVector v) {

    }
}

class ObjGroup extends DynObject {
    private List<DynObject> list;

    public ObjGroup() {
        super();
        list = new ArrayList<DynObject>();
    }

    public void add(DynObject obj) {
        list.add(obj);
    }
}

class DynScene {
    private List<DynObject> list;

    public DynScene() {
        list = new ArrayList<DynObject>();
    }
}