PGraphics main,hud;
SceneManager manager = new SceneManager();
String devText = "";

void setup() {
    size(1920,1080,P3D);
    main = createGraphics(1920,1061,P3D);
    main.smooth(8);
    hud = createGraphics(1920,1080,P2D);
    noStroke();
    fill(50,50,50);
    PShape shape1 = createShape(BOX,50,1,50);
    MapTile m1 = new MapTile('A',shape1,true);
    tileMap.put('A',m1);
    fill(100,100,100);
    PShape shape2 = createShape(BOX,50,1,50);
    MapTile m2 = new MapTile('B',shape2,true);
    tileMap.put('B',m2);
    fill(0,255,0);
    PShape shape3 = createShape(BOX,50,50,50);
    shape3.translate(0,-25,0);
    MapTile m3 = new MapTile('C',shape3);
    tileMap.put('C',m3);
    emissive(#FFA500);
    fill(0);
    PShape shape4 = createShape(BOX,50,1,50);
    shape4.translate(0,1,0);
    MapTile m4 = new DangerTile('L',shape4);
    tileMap.put('L',m4);
    emissive(#000000);


    Character[][] map1 = 
    {
        {'C','L','A','B','A','L'},
        {'C','L','B','A','B','L'},
        {'C','B','A','B','A','L'},
        {'C','L','B','A','B','L'},
        {'C','L','A','B','A','L'} 
    };
    NavMap navmap1 = new NavMap(map1);

    stroke(0);
    fill(255,255,255);
    PShape ent1 = createShape(BOX,50,50,50);
    ent1.translate(0,-26,0);
    Player e1 = new Player(2,3,ent1);
    navmap1.registerEntity(e1);

    manager.registerMap(navmap1);

    Character[][] map2 = 
    {
        {'A','B','C','B','A','B'},
        {'B','A','C','A','L','A'},
        {'A','B','C','B','L','B'},
        {'B','A','C','A','L','A'},
        {'A','B','A','B','L','B'} 
    };
    NavMap navmap2 = new NavMap(map2);

    stroke(0);
    fill(255,255,255);
    PShape ent2 = createShape(BOX,50,50,50);
    ent2.translate(0,-26,0);
    Player e2 = new Player(2,3,ent2);
    navmap2.registerEntity(e2);

    manager.registerMap(navmap2);
}

void draw() {
    main.beginDraw();

    //Background & Lighting
    main.background(0,0,0);
    main.ambientLight(75,75,75);
    main.directionalLight(150,150,150,1,1,1);

    //Camera
    main.beginCamera();
    main.camera();
    main.translate(1920/2,1080/2,0);
    main.rotateX(radians(-45));
    main.rotateY(radians(-10));
    main.endCamera();
    //scene offset
    main.translate(-150,0,-100);
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
    NavMap act = manager.getActiveMap();
    if (key == 'w') {
        act.moveEnt(manager.getPlayer(),Direction.UP);
    }
    if (key == 's') {
        act.moveEnt(manager.getPlayer(),Direction.DOWN);
    }
    if (key == 'a') {
        act.moveEnt(manager.getPlayer(),Direction.LEFT);
    }
    if (key == 'd') {
        act.moveEnt(manager.getPlayer(),Direction.RIGHT);
    }
    if (key == 10) {
        manager.nextScene();
    }
}