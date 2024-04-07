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
    fill(50);
    PShape shape1 = createShape(BOX,50,1,50);
    MapTile m1 = new MapTile('T',shape1,true);
    tileMap.put('T',m1);
    fill(100);
    PShape shape2 = createShape(BOX,50,1,50);
    MapTile m2 = new MapTile('F',shape2,true);
    tileMap.put('F',m2);
    fill(25);
    PShape shape3 = createShape(BOX,50,50,50);
    shape3.translate(0,-25,0);
    MapTile m3 = new MapTile('W',shape3);
    tileMap.put('W',m3);
    fill(#FFA500);
    PShape shape4 = createShape(BOX,50,50,50);
    shape4.translate(0,24,0);
    MapTile m4 = new DangerTile('L',shape4);
    tileMap.put('L',m4);
    fill(0,255,0);
    PShape shape5 = createShape(BOX,50,1,50);
    MapTile m5 = new WinTile('V',shape5);
    tileMap.put('V',m5);

    //Generating Entities, could in theory be put into a JSON to be loaded for later use.
    EntFunction walkUp = (n) -> {manager.getActiveMap().moveEnt(n,Direction.UP);};
    EntFunction walkDown = (n) -> {manager.getActiveMap().moveEnt(n,Direction.DOWN);};
    EntFunction walkLeft = (n) -> {manager.getActiveMap().moveEnt(n,Direction.LEFT);};
    EntFunction walkRight = (n) -> {manager.getActiveMap().moveEnt(n,Direction.RIGHT);};
    EntFunction entdie = (n) -> {n.kill();};



    strokeWeight(1);
    stroke(0);
    fill(255,255,255);
    PShape ent1 = createShape(BOX,40,40,40);
    ent1.translate(0,-21,0);
    Player e1 = new Player(0,0,ent1);
    KeyFrame[] wuframes = {new KeyFrame(10,90,0,0,new PVector(0,-19,-30))};
    Animation aWalkUp = new Animation(
        wuframes,
        false,
        false,
        walkUp,
        e1
    );
    KeyFrame[] wdframes = {new KeyFrame(10,-90,0,0,new PVector(0,-19,30))};
    Animation aWalkDown = new Animation(
        wdframes,
        false,
        false,
        walkDown,
        e1
    );
    KeyFrame[] wlframes = {new KeyFrame(10,0,0,-90,new PVector(-30,-19,0))};
    Animation aWalkLeft = new Animation(
        wlframes,
        false,
        false,
        walkLeft,
        e1
    );
    KeyFrame[] wrframes = {new KeyFrame(10,0,0,90,new PVector(30,-19,0))};
    Animation aWalkRight = new Animation(
        wrframes,
        false,
        false,
        walkRight,
        e1
    );
    KeyFrame[] ldieframes = {new KeyFrame(70,0,0,0,new PVector(0,50,0))};
    Animation aLDie = new Animation(
        ldieframes,
        false,
        false,
        entdie,
        e1,
        true
    );
    e1.registerAnimation("walkUp", aWalkUp);
    e1.registerAnimation("walkDown", aWalkDown);
    e1.registerAnimation("walkLeft", aWalkLeft);
    e1.registerAnimation("walkRight", aWalkRight);
    e1.registerAnimation("lavaDeath", aLDie);
    entityMap.put("player",e1);
    noStroke();


    //Generating Maps
    Character[][] map1 = 
    {
        {'W','F','T','F','T','L'},
        {'W','T','L','b','F','L'},
        {'W','V','L','F','T','L'},
        {'W','T','L','b','F','L'},
        {'W','F','T','F','T','L'} 
    };
    NavMap navmap1 = new NavMap(map1);
    navmap1.registerEntity(entityMap.get("player"),2,3);
    manager.registerMap(navmap1);

    Character[][] map2 = 
    {
        {'V','W','F','T','F'},
        {'T','W','T','L','T'},
        {'F','W','F','L','F'},
        {'T','W','T','L','T'},
        {'F','W','F','L','F'},
        {'T','F','T','L','T'} 
    };
    NavMap navmap2 = new NavMap(map2);
    navmap2.registerEntity(entityMap.get("player"),5,4);
    manager.registerMap(navmap2);

    Character[][] map3 = 
    {                   //C
        {'W','W','T','F','T','b','b','b','V'},
        {'W','W','F','W','F','T','F','T','F'},
        {'T','F','T','W','b','b','b','b','b'},
        {'F','W','W','W','F','T','F','T','F'},
        {'T','F','T','W','T','b','b','b','T'},//C
        {'W','W','F','W','b','b','b','b','F'},
        {'T','F','T','W','T','F','T','b','T'},
        {'F','W','W','W','F','b','F','b','F'},
        {'T','F','T','F','T','b','T','F','T'}
    };
    NavMap navmap3 = new NavMap(map3);
    navmap3.registerEntity(entityMap.get("player"),4,4);
    manager.registerMap(navmap3);

    Character[][] map4 = 
    {                   //C
        {'W','W','W','W','W','W','W','W','W'},
        {'W','W','F','T','F','W','F','T','F'},
        {'W','W','T','W','T','W','T','W','T'},
        {'W','W','F','W','F','W','F','W','F'},
        {'W','F','T','L','T','L','T','L','T'},//C
        {'W','W','F','W','F','W','F','W','F'},
        {'W','W','T','W','T','W','T','W','T'},
        {'W','W','F','W','F','W','F','W','F'},
        {'W','W','T','W','T','F','T','W','V'}
    };
    NavMap navmap4 = new NavMap(map4);
    navmap4.registerEntity(entityMap.get("player"),8,2);
    manager.registerMap(navmap4); 
    
    Character[][] map5 = 
    {                   //C
        {'V','F','T','F','T','F','T','F','T'},
        {'b','b','b','b','b','b','b','b','F'},
        {'b','F','T','F','T','F','T','F','T'},
        {'b','T','b','b','b','b','b','b','b'},
        {'b','F','T','F','T','F','T','F','T'},//C
        {'b','L','L','L','L','L','L','L','F'},
        {'b','T','T','F','T','F','T','F','T'},
        {'b','F','L','L','L','L','L','L','L'},
        {'b','T','T','F','T','F','T','F','T'}
    };
    NavMap navmap5 = new NavMap(map5);
    navmap5.registerEntity(entityMap.get("player"),8,7);
    manager.registerMap(navmap5); 
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
    for(ReferencedLamda r : functionManager) {
        r.run();
    }
    functionManager = new ArrayList<ReferencedLamda>();
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
    if (key == 'r') {
        manager.reload();
    }
    if (key == 'q') {
        camRotY += 45;
    }
    if (key == 'e') {
        camRotY -= 45;
    }
    if (key == 10) {
        manager.nextScene();
    }
    if (camRotY < 0) {
        camRotY += 360;
    }
    if (camRotY > 360) {
        camRotY -= 360;
    }
}