float camRotY;
PGraphics main,hud;
SceneManager manager = new SceneManager();
String devText = "";

void setup() {
    size(1920,1080,P3D);
    main = createGraphics(1920,1061,P3D);
    main.smooth(8);
    hud = createGraphics(1920,1080,P2D);
    noStroke();

    //Generating Tiles, could in theory be put into a JSON to be loaded for later use.
    fill(50,50,50);
    PShape shape1 = createShape(BOX,50,1,50);
    MapTile m1 = new MapTile('T',shape1,true);
    tileMap.put('T',m1);
    fill(100,100,100);
    PShape shape2 = createShape(BOX,50,1,50);
    MapTile m2 = new MapTile('F',shape2,true);
    tileMap.put('F',m2);
    fill(25);
    PShape shape3 = createShape(BOX,50,50,50);
    shape3.translate(0,-25,0);
    MapTile m3 = new MapTile('W',shape3);
    tileMap.put('W',m3);
    emissive(#FFA500);
    fill(0);
    PShape shape4 = createShape(BOX,50,1,50);
    shape4.translate(0,1,0);
    MapTile m4 = new DangerTile('L',shape4);
    tileMap.put('L',m4);
    emissive(#000000);
    fill(0,255,0);
    PShape shape5 = createShape(BOX,50,1,50);
    MapTile m5 = new WinTile('V',shape5);
    tileMap.put('V',m5);

    //Generating Entities, could in theory be put into a JSON to be loaded for later use.
    stroke(0);
    fill(255,255,255);
    PShape ent1 = createShape(BOX,50,50,50);
    ent1.translate(0,-26,0);
    Player e1 = new Player(0,0,ent1);
    entityMap.put("player",e1);

    Character[][] map1 = 
    {
        {'W','L','T','F','T','L'},
        {'W','L','b','b','F','L'},
        {'W','V','T','F','T','L'},
        {'W','L','b','b','F','L'},
        {'W','L','T','F','T','L'} 
    };
    NavMap navmap1 = new NavMap(map1);
    navmap1.registerEntity(entityMap.get("player"),2,3);
    manager.registerMap(navmap1);

    Character[][] map2 = 
    {
        {'T','V','W','F','T','F'},
        {'F','T','W','T','L','T'},
        {'T','F','W','F','L','F'},
        {'F','T','W','T','L','T'},
        {'T','F','T','F','L','F'} 
    };
    NavMap navmap2 = new NavMap(map2);
    navmap2.registerEntity(entityMap.get("player"),2,3);
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
}

void draw() {
    main.beginDraw();

    //Background & Lighting
    main.background(90,90,100);
    main.ambientLight(75,75,75);
    main.directionalLight(200,200,200,-1,1,-1);

    //Camera
    main.beginCamera();
    main.camera();
    main.translate(1920/2,1080/2,0);
    main.rotateX(radians(-55));
    main.rotateY(radians(-20+camRotY));
    main.endCamera();
    //scene offset
    main.translate(-manager.getActiveMap().tiles.length*0.5*50,0,-manager.getActiveMap().tiles[0].length*0.5*50);
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
    if (key == 'r') {
        manager.reload();
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