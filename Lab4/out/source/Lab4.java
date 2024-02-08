/* autogenerated by Processing revision 1293 on 2024-02-06 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class Lab4 extends PApplet {



PGraphics background, foreground, subject;
Thread bgDraw, fgDraw, subDraw;
StarMap starmap;

public void setup() {
    /* size commented out by preprocessor */;
    frameRate(8);
    starmap = new StarMap();
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

public void draw() {
    background(0);
    image(background, 0, 0);
    image(foreground, 0, 0);
    image(subject, 0, 0);
}

public void prepareBackground() {
    background.beginDraw();
    background.background(30);

    //setting up values
    float freq1, freq2;
    float[] map = new float[background.width*background.height];
    float mapmax = 0;
    float mapmin = 1;
    freq1 = 0.003f;
    freq2 = 0.01f;


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
            float comp = n*0.7f+d*0.3f;
            comp += 1.0f;
            comp *= 0.5f; //avoiding division

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
    int minGap = 2; //min number of pixels between each star.
    int starSize = 4; //max size of stars
    float starWeight = 0.05f; //influences the number of stars generated, higher is more.

    for(int y = 0; y < background.height; y++) {
        int backy = y*background.width;
        for (int x = 0; x < background.width; x++) {
            //exponential random function so stars are clustered around light points.
            float val = (float) Math.log(Math.random())/((float) -normalize(map[backy+x],mapmin,mapmax)*starWeight);
            if (val < 0.1f) {
                //testing if the generated star is too close to an existing one (as defined by minGap)
                //this is pretty slow, because it reduces this loop to O(N^3) but other approaches like GLSL compute shaders would be a bit too time intensive for me to work on right now.
                UStar nearest = starmap.nearestNeighbor(x,y);
                float dist = distance(x,nearest.posX(),y,nearest.posY());
                if (dist > minGap) {
                    UStar star;
                    int colOff = (int) Math.round(Math.random() * (105 - 5) + 5);
                    int col = color(150,150,150+colOff);
                    int size = (int) Math.round(Math.random() * (starSize - 1) + 1);
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
    stars.filter(BLUR, 1.2f);
    stars.endDraw();

    background.beginDraw();
    background.image(stars,0,0);
    background.endDraw();
}

public void prepareForeground() {
    foreground.beginDraw();

    float freq1, freq2;
    freq1 = 0.01f;
    freq2 = 0.005f;

    //Define the ground area
    foreground.fill(100, 119, 192);
    foreground.beginShape();
    foreground.vertex(0, 570);
    foreground.vertex(1000, 520);
    foreground.vertex(1000, 900);
    foreground.vertex(0, 900);
    foreground.endShape(CLOSE);

    //more perlin noise for splatter
    int itterations = 4;
    for (int i = 0; i < itterations; i++) {
        foreground.loadPixels();
        for(int y = 0; y < foreground.height; y++) {
            //precomputing all y values to help save on render time
            float prey1 = y*freq1;
            float prey2 = y*freq2;
            int backy = y*foreground.width;
            for (int x = 0; x < foreground.width; x++) {
                int col = foreground.pixels[backy+x];
                float alph = alpha(foreground.pixels[backy+x]);
                float adjAlpha = normalize(75,0,255);
                if (alph == 0) {
                    continue;
                }
                //generating base noise values
                float n1 = noise(x*freq1, prey1,i);
                float n2 = noise(x*freq2, prey2,i+itterations);
                float n = (n1*0.6f+n2*0.4f);
                n += 1;
                n *= 0.5f;
                //clamping and normalizing to try and get a roughly "splatter like" pattern
                n = shunt(n, 0.75f, 1.0f);
                n = normalize(n, 0.75f, 0.76f);
                int c = (int) Math.round(n*255);
                int ncol = color(c-30,c-30,c);
                int fcol = lerpColor(col, ncol, adjAlpha);
                if (c == 0) {
                    fcol = col;
                }
                foreground.pixels[backy+x] = color(red(fcol),green(fcol),blue(fcol),alph);
            }
        }
        foreground.updatePixels();
    }
    foreground.filter(BLUR, 1.5f);

    foreground.endDraw();
}

public void prepareSubject() {

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
    int col;
    
    public UStar(int x, int y, int r, int col) {
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

    public int col() {
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


  public void settings() { size(1000, 900); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Lab4" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
