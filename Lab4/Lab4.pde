import java.util.*;

PGraphics background, foreground, subject;
Thread bgDraw, fgDraw, subDraw;
StarMap starmap;
DynScene dyscene;

void setup() {
    size(1000, 900);
    frameRate(8);
    starmap = new StarMap();
    dyscene = new DynScene();
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

    //fgDraw.suspend();
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
    //fgDraw.resume();

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

    /*
    * more perlin noise for splatter
    *
    * this function causes some strange behavior with the star generation, I think it has to do with simultaneous sampling of the noise() function since it wasnt set up for asyn operation.
    * consider implementing a custom perlin noise sampler to sidestep this issue.
    * 
    * Presently, suspending the background thread until the splatter is drawn sidesteps the issue (the reverse did not work) however this somewhat defeats the point of async drawing,
    * even if it still retains some advantages due to the subject drawing being async.
    */
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
}

void prepareSubject() {
    //prepare dynamic objects
    //Left Foot
    List<PVector> LFP = Arrays.asList(new PVector(383,700),new PVector(433,700),new PVector(447,768),new PVector(321,790),new PVector(285,786),new PVector(285,759));
    color LFC = color(195,195,195);
    PVector LFPOS = new PVector(381, 747);
    DynObject LF = new DynObject(LFPOS, AbsToRel(LFPOS, LFP), LFC, -1);
    dyscene.add(LF);

    //Right Foot
    List<PVector> RFP = Arrays.asList(new PVector(709,742), new PVector(723,735), new PVector(743,712), new PVector(752,686), new PVector(766,768), new PVector(755,813), new PVector(710,823), new PVector(681,815), new PVector(673,798), new PVector(686,776), new PVector(697,772));
    color RFC = color(195,195,195);
    PVector RFPOS = new PVector(730, 757);
    DynObject RF = new DynObject(RFPOS, AbsToRel(RFPOS, RFP), RFC, 1);
    dyscene.add(RF);

    dyscene.sort();
    println(dyscene.toString());
}

void animateObjects() {
    subject.beginDraw();
    dyscene.renderAll(subject);
    subject.endDraw();
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

public List<PVector> AbsToRel(PVector pos, List<PVector> list) {
    List<PVector> relList = new ArrayList<PVector>();
    for (PVector item : list) {
        relList.add(new PVector(item.x-pos.x,item.y-pos.y));
    }
    return relList;
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

class DynObject implements Comparable<DynObject>{
    private PVector position; //origin of the object, can be any point in space that all points are relative to.
    private List<PVector> verts; //relative to positon in space
    private color fill;
    private int layer; //determines order of rendering

    public DynObject() {
        this.position = new PVector(0,0);
        this.verts = new ArrayList<PVector>();
        this.fill = color(0,0,0); 
        this.layer = 0;
    }

    public DynObject(PVector position, List<PVector> vertexes, color fill, int layer) {
        this.position = position;
        this.verts = vertexes;
        this.fill = fill;
        this.layer = layer;
    }

    //render to screen
    public void render() {
        fill(this.fill);
        beginShape();
        for (PVector vert : verts) {
            vertex(vert.x+position.x,vert.y+position.y);
        }
        endShape(CLOSE);
    }

    //render to a specific buffer
    public void render(PGraphics buffer) {
        buffer.fill(this.fill);
        buffer.beginShape();
        for (PVector vert : verts) {
            buffer.vertex(vert.x+position.x,vert.y+position.y);
        }
        buffer.endShape(CLOSE);
    }

    //absolute movement
    public void move(PVector v) {
        position = v;
    }

    //relative movement
    public void nudge(PVector v) {
        position.x += v.x;
        position.y += v.y;
    }

    public int getLayer() {
        return layer;
    }

    public PVector getPos() {
        return position;
    }

  @Override
	public int compareTo(DynObject d) {
		return this.layer - d.getLayer();
	} 
}

class ObjGroup extends DynObject {
    private List<DynObject> list;

    public ObjGroup() {
        super();
        list = new ArrayList<DynObject>();
    }

    public ObjGroup(DynObject... objs) {
        super();
        list = Arrays.asList(objs);
    }

    @Override
    public void render() {
        for (DynObject obj : list) {
            obj.render();
        }
    }

    @Override
    public void render(PGraphics buffer) {
        for (DynObject obj : list) {
            obj.render(buffer);
        }
    }

    public void add(DynObject obj) {
        list.add(obj);
    }

    @Override
    public void move(PVector v) {
        super.move(v);
        for (DynObject item : list) {
            item.move(v);
        }
    }

    @Override
    public void nudge(PVector v) {
        super.nudge(v);
        for (DynObject item : list) {
            item.nudge(v);
        }
    }
}

class DynScene {
    private List<DynObject> list;
    private int minLayer;
    private int maxLayer;

    public DynScene() {
        list = new ArrayList<DynObject>();
        minLayer = 99999999;
        maxLayer = -99999999;
    }

    public void add(DynObject o) {
        int layer = o.getLayer();
        if (layer > maxLayer) {
            maxLayer = layer;
        }
        if (layer < minLayer) {
            minLayer = layer;
        }
        list.add(o);
    }

    //this is required to be run before rendering can be performed.
    public void sort() {
        Collections.sort(list);
    }

    public void renderAll() {
        for (int i = minLayer; i <= maxLayer; i++) {        
            for (DynObject obj : list) {
                if (obj.getLayer() == i) {
                    obj.render();
                }
            }
        }
    }

    public void renderAll(PGraphics buffer) {
        for (int i = minLayer; i <= maxLayer; i++) { 
          for (DynObject obj : list) {
              if (obj.getLayer() == i) {
                  obj.render(buffer);
              }
          }
        }
    }

    public void renderLayer(int renderTarget) {
        for (DynObject obj : list) {
            if (obj.getLayer() == renderTarget) {
                obj.render();
            }
        }
    }

    public void renderLayer(int renderTarget, PGraphics buffer) {
        for (DynObject obj : list) {
            if (obj.getLayer() == renderTarget) {
                obj.render(buffer);
            }
        }
    }

    @Override
    public String toString() {
        String out = "{";
        for (DynObject obj : list) {
            PVector pos = obj.getPos();
            out += "["+pos.x+","+pos.y+", "+obj.getLayer()+"] ";
        }
        out += "[MinLayer: "+minLayer+",";
        out += "MaxLayer: "+maxLayer+"]";
        out += "}";
        return out;
    }
}
