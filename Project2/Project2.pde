import java.util.function.Consumer;
import java.util.Arrays;

float camRotY;
PShader lighting;
PGraphics main,hud;
SceneManager manager = new SceneManager();
String devText = "";
ArrayList<ReferencedLamda> functionManager = new ArrayList<ReferencedLamda>();
boolean holding = false;

void setup() {
    size(1920,1080,P3D);
    frameRate(60);
    main = createGraphics(1920,1061,P3D);
    main.smooth(8);
    hud = createGraphics(1920,1080,P2D);
    noStroke();

    //Shaders, still experementing with/testing these
    /*
    lighting = loadShader("./shaders/Lighting/lightingFrag.glsl","./shaders/Lighting/lightingVert.glsl");
    lighting.set("ambientColor", 150f, 150f, 150f);
    lighting.set("ambientStrength",1f);
    lighting.set("lightColor", 200f, 200f, 200f);
    lighting.set("lightDir", 0.2f, -1f, 0.6f);
    lighting.set("specStrength", 1f);
    lighting.set("viewPos",-200,-650,-400);*/


    //Generating Tiles, could in theory be put into a JSON to be loaded for later use.
    defineTiles();

    //Generating Entities, could in theory be put into a JSON to be loaded for later use.
    defineEntities();

    //Generating Maps
    defineMaps();

    //Generating Hud Elements
    defineHudElements();
}

void draw() {
    main.beginDraw();

    if (holding) {
        keyHeld();
    }

    //Background & Lighting
    main.background(50,50,60);
    main.ambientLight(150, 150, 150);
    main.directionalLight(200, 200, 200, -0.2, 1, -0.6);

    //load main shader
    //main.shader(lighting);

    //Camera
    main.beginCamera();
    main.camera();
    main.translate(1920/2,1080/2,0);
    main.rotateX(radians(-55));
    main.rotateY(radians(-20+camRotY));
    main.endCamera();
    //scene offset
    //dev marks, useful as a reference
    /*
    main.stroke(0, 255, 0, 255);
    main.strokeWeight(2);
    main.line(0, -1000, 0, 0, 1000, 0);
    main.stroke(255, 0, 0, 255);
    main.line(-1000, 0, 0, 1000, 0, 0);
    main.stroke(0, 0, 255, 255);
    main.line(0, 0, -1000, 0, 0, 1000);
    main.noStroke();
    main.fill(255);
    main.pushMatrix();
    main.translate(200,-650,400);
    main.sphere(10);
    main.popMatrix(); */

    //translating the scene to the center of the screen & drawing
    main.translate(-manager.getActiveMap().tiles.length*0.5*50,0,-manager.getActiveMap().tiles[0].length*0.5*50);
    int size = functionManager.size();
    ArrayList<ReferencedLamda> cleanup = new ArrayList<ReferencedLamda>();
    for(int x = 0; x < size; x++) {
        ReferencedLamda r = functionManager.get(x);
        r.run();
        cleanup.add(r);
    }
    for (ReferencedLamda r : cleanup) {
        functionManager.remove(r);
    }
    cleanup = new ArrayList<ReferencedLamda>();
    manager.getActiveMap().drawMap(main);
    main.endDraw();

    hud.beginDraw();
    hud.background(0,0,0,0);
    hud.noStroke();
    hud.fill(255, 255, 255);
    hud.textSize(64);
    hud.text("Current Pos: "+devText, 0, 64);
    hud.text("Current State: "+manager.getPlayer().state, 0, 128);
    hud.endDraw();

    image(main,0,0);
    image(hud,0,0);
}

void keyPressed() {
    holding = true;
    if (key == 'r') {
        manager.reload();
    }
    if (key == 10) {
        manager.nextScene();
    }
    keyHeld();
}

void keyReleased() {
    holding = false;    
}

void keyHeld() {
    NavMap act = manager.getActiveMap();
    if (key == 'w') {
        try {
            if (act.checkEnt(act.getPlayer(),Direction.UP)) {
                act.getPlayer().playAnimation("walkUp");
            }
        } catch (Exception e) {
            println(e.toString());
        }
    }
    if (key == 's') {
        try {
            if (act.checkEnt(act.getPlayer(),Direction.DOWN)) {
                act.getPlayer().playAnimation("walkDown");
            }
        } catch (Exception e) {
            println(e.toString());
        }
    }
    if (key == 'a') {
        try {
            if (act.checkEnt(act.getPlayer(),Direction.LEFT)) {
                act.getPlayer().playAnimation("walkLeft");
            }
        } catch (Exception e) {
            println(e.toString());
        }
    }
    if (key == 'd') {
        try {
            if (act.checkEnt(act.getPlayer(),Direction.RIGHT)) {
                act.getPlayer().playAnimation("walkRight");
            }
        } catch (Exception e) {
            println(e.toString());
        }
    }
    if (key == 'q') {
        camRotY += 5;
    }
    if (key == 'e') {
        camRotY -= 5;
    }
    if (camRotY < 0) {
        camRotY += 360;
    }
    if (camRotY > 360) {
        camRotY -= 360;
    }
}