public void defineTiles() {
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
}

public void defineEntities() {
    //Defining Common Functions
    EntFunction entdie = (n) -> {
        println(n.toString() + " Dead");
        n.kill();
    };     
    EntFunction entnothing = (n) -> {};    
    EntFunction entStartUp = (n) -> {
        n.intendedX = n.mapX;
        n.intendedY = n.mapY-1;
    };
    EntFunction entStartDown = (n) -> {
        n.intendedX = n.mapX;
        n.intendedY = n.mapY+1;
    };
    EntFunction entStartLeft = (n) -> {
        n.intendedX = n.mapX-1;
        n.intendedY = n.mapY;
    };
    EntFunction entStartRight = (n) -> {
        n.intendedX = n.mapX+1;
        n.intendedY = n.mapY;
    };    
    EntFunction entStartUpCol = (n) -> {
        n.intendedX = n.mapX;
        n.intendedY = n.mapY-1;
        n.checkColide(n.intendedX,n.intendedY);
    };
    EntFunction entStartDownCol = (n) -> {
        n.intendedX = n.mapX;
        n.intendedY = n.mapY+1;
        n.checkColide(n.intendedX,n.intendedY);
    };
    EntFunction entStartLeftCol = (n) -> {
        n.intendedX = n.mapX-1;
        n.intendedY = n.mapY;
        n.checkColide(n.intendedX,n.intendedY);
    };
    EntFunction entStartRightCol = (n) -> {
        n.intendedX = n.mapX+1;
        n.intendedY = n.mapY;
        n.checkColide(n.intendedX,n.intendedY);
    };

    strokeWeight(1);
    stroke(0);
    fill(255,255,255);
    //creating Player
    PShape ent1 = createShape(BOX,40,40,40);
    ent1.translate(0,-21,0);
    Player e1 = new Player(0,0,ent1);
    //Designing Animations & Ending functions
    EntFunction walkUp = (n) -> {
        manager.getActiveMap().moveEnt(n,Direction.UP);
        n.checkColide(n.intendedX,n.intendedY);
    };
    EntFunction walkDown = (n) -> {
        manager.getActiveMap().moveEnt(n,Direction.DOWN);
        n.checkColide(n.intendedX,n.intendedY);
    };
    EntFunction walkLeft = (n) -> {
        manager.getActiveMap().moveEnt(n,Direction.LEFT);
        n.checkColide(n.intendedX,n.intendedY);
    };
    EntFunction walkRight = (n) -> {
        manager.getActiveMap().moveEnt(n,Direction.RIGHT);
        n.checkColide(n.intendedX,n.intendedY);
    };

    KeyFrame[] wuframes = {new KeyFrame(10,90,0,0,1,new PVector(0,-19,-30))};
    Animation aWalkUp = new Animation(
        "walkUp",
        wuframes,
        false,
        false,
        true,
        entStartUp,
        walkUp
    );
    KeyFrame[] wdframes = {new KeyFrame(10,-90,0,0,1,new PVector(0,-19,30))};
    Animation aWalkDown = new Animation(
        "walkDown",
        wdframes,
        false,
        false,
        true,
        entStartDown,
        walkDown
    );
    KeyFrame[] wlframes = {new KeyFrame(10,0,0,-90,1,new PVector(-30,-19,0))};
    Animation aWalkLeft = new Animation(
        "walkLeft",
        wlframes,
        false,
        false,
        true,
        entStartLeft,
        walkLeft
    );
    KeyFrame[] wrframes = {new KeyFrame(10,0,0,90,1,new PVector(30,-19,0))};
    Animation aWalkRight = new Animation(
        "walkRight",
        wrframes,
        false,
        false,
        true,
        entStartRight,
        walkRight
    );
    KeyFrame[] ldieframes = {new KeyFrame(70,0,0,0,1,new PVector(0,50,0))};
    Animation aLDie = new Animation(
        "lavaDeath",
        ldieframes,
        false,
        false,
        false,
        entnothing,
        entdie,
        true
    );
    KeyFrame[] ndieframes = {new KeyFrame(30,0,0,0,0,new PVector(0,0,0))};
    Animation aNDie = new Animation(
        "normalDeath",
        ndieframes,
        false,
        false,
        false,
        entnothing,
        entdie,
        true
    );
    //Registering Animations
    e1.registerAnimation("walkUp", aWalkUp);
    e1.registerAnimation("walkDown", aWalkDown);
    e1.registerAnimation("walkLeft", aWalkLeft);
    e1.registerAnimation("walkRight", aWalkRight);
    e1.registerAnimation("lavaDeath", aLDie);
    e1.registerAnimation("normalDeath", aNDie);
    //Registering Player to entity map for later use & reference
    entityMap.put("player",e1);

    //Creating Line Enemies
    fill(#FF0000);
    PShape ent2 = createShape(BOX,20,40,20);
    ent2.translate(0,-21,0);
    LineEnemy e2 = new LineEnemy(0,0,ent2,2,Direction.UP);
    LineEnemy e3 = new LineEnemy(0,0,ent2,2,Direction.DOWN);
    LineEnemy e4 = new LineEnemy(0,0,ent2,2,Direction.LEFT);
    LineEnemy e5 = new LineEnemy(0,0,ent2,2,Direction.RIGHT);

    //Registering Enemy Functions
    EntFunction eIdle = (n) -> {
        AIEntity a = (AIEntity) n;
        a.ai = AIState.WAITING;
    };
    EntFunction enWalkUp = (n) -> {
        manager.getActiveMap().moveEnt(n,Direction.UP);
        n.checkColide(n.intendedX,n.intendedY);
        AIEntity a = (AIEntity) n;
        a.ai = AIState.WAITING;
    };
    EntFunction enWalkDown = (n) -> {
        manager.getActiveMap().moveEnt(n,Direction.DOWN);
        n.checkColide(n.intendedX,n.intendedY);
        AIEntity a = (AIEntity) n;
        a.ai = AIState.WAITING;
    };
    EntFunction enWalkLeft = (n) -> {
        manager.getActiveMap().moveEnt(n,Direction.LEFT);
        n.checkColide(n.intendedX,n.intendedY);
        AIEntity a = (AIEntity) n;
        a.ai = AIState.WAITING;
    };
    EntFunction enWalkRight = (n) -> {
        manager.getActiveMap().moveEnt(n,Direction.RIGHT);
        n.checkColide(n.intendedX,n.intendedY);
        AIEntity a = (AIEntity) n;
        a.ai = AIState.WAITING;
    };
    EntFunction enTurnAround = (n) -> {
        LineEnemy a = (LineEnemy) n;
        if (a.dir == Direction.UP) {
            a.dir = Direction.DOWN;
        } else if (a.dir == Direction.DOWN) {
            a.dir = Direction.UP;
        } else if (a.dir == Direction.LEFT) {
            a.dir = Direction.RIGHT;
        } else if (a.dir == Direction.RIGHT) {
            a.dir = Direction.LEFT;
        }
        a.ai = AIState.WAITING;
    };

    KeyFrame[] eidleframes = {new KeyFrame(10,0,0,0,1,new PVector(0,00,0)),new KeyFrame(5,0,0,0,1,new PVector(0,-10,0)), new KeyFrame(5,0,0,0,1,new PVector(0,0,0)),new KeyFrame(10,0,0,0,1,new PVector(0,0,0))};
    Animation aEnemyIdle = new Animation(
        "idle",
        eidleframes,
        false,
        true,
        false,
        entnothing,
        eIdle
    );    
    KeyFrame[] enTurnAroundframes = {new KeyFrame(5,0,90,0,1,new PVector(0,-10,0)), new KeyFrame(5,0,180,0,1,new PVector(0,0,0))};
    Animation aEnTurnAround = new Animation(
        "turnAround",
        enTurnAroundframes,
        false,
        false,
        false,
        entnothing,
        enTurnAround,
        true
    );
    KeyFrame[] enWalkUpframes = {new KeyFrame(5,0,0,0,1,new PVector(0,-10,-25)), new KeyFrame(5,0,0,0,1,new PVector(0,0,-50))};
    Animation aEnWalkUp = new Animation(
        "walkUp",
        enWalkUpframes,
        false,
        false,
        true,
        entStartUpCol,
        enWalkUp
    );
    KeyFrame[] enWalkDownframes = {new KeyFrame(5,0,0,0,1,new PVector(0,-10,25)),new KeyFrame(5,0,0,0,1,new PVector(0,0,50))};
    Animation aEnWalkDown = new Animation(
        "walkDown",
        enWalkDownframes,
        false,
        false,
        true,
        entStartDownCol,
        enWalkDown
    );
    KeyFrame[] enWalkLeftframes = {new KeyFrame(5,0,0,0,1,new PVector(-25,-10,0)),new KeyFrame(5,0,0,0,1,new PVector(-50,0,0))};
    Animation aEnWalkLeft = new Animation(
        "walkLeft",
        enWalkLeftframes,
        false,
        false,
        true,
        entStartLeftCol,
        enWalkLeft
    );
    KeyFrame[] enWalkRightframes = {new KeyFrame(5,0,0,0,1,new PVector(25,-10,0)), new KeyFrame(5,0,0,0,1,new PVector(50,0,0))};
    Animation aEnWalkRight = new Animation(
        "walkRight",
        enWalkRightframes,
        false,
        false,
        true,
        entStartRightCol,
        enWalkRight
    );
    e2.registerAnimation("idle", aEnemyIdle);
    e2.registerAnimation("turnAround", aEnTurnAround);
    e2.registerAnimation("walkUp", aEnWalkUp);
    e2.registerAnimation("walkDown", aEnWalkDown);
    e2.registerAnimation("walkLeft", aEnWalkLeft);
    e2.registerAnimation("walkRight", aEnWalkRight);
    e3.registerAnimation("idle", aEnemyIdle);
    e3.registerAnimation("turnAround", aEnTurnAround);
    e3.registerAnimation("walkUp", aEnWalkUp);
    e3.registerAnimation("walkDown", aEnWalkDown);
    e3.registerAnimation("walkLeft", aEnWalkLeft);
    e3.registerAnimation("walkRight", aEnWalkRight);
    e4.registerAnimation("idle", aEnemyIdle);
    e4.registerAnimation("turnAround", aEnTurnAround);
    e4.registerAnimation("walkUp", aEnWalkUp);
    e4.registerAnimation("walkDown", aEnWalkDown);
    e4.registerAnimation("walkLeft", aEnWalkLeft);
    e4.registerAnimation("walkRight", aEnWalkRight);
    e5.registerAnimation("idle", aEnemyIdle);
    e5.registerAnimation("turnAround", aEnTurnAround);
    e5.registerAnimation("walkUp", aEnWalkUp);
    e5.registerAnimation("walkDown", aEnWalkDown);
    e5.registerAnimation("walkLeft", aEnWalkLeft);
    e5.registerAnimation("walkRight", aEnWalkRight);
    entityMap.put("upLineEnemy",e2);
    entityMap.put("downLineEnemy",e3);
    entityMap.put("leftLineEnemy",e4);
    entityMap.put("rightLineEnemy",e5);
    fill(255);
    noStroke();
}

public void defineMaps() {
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
    navmap4.registerEntity(entityMap.get("downLineEnemy"),4,1);
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
        {'b','F','T','F','T','F','T','F','T'},
        {'b','T','L','L','L','L','L','L','L'},
        {'b','F','T','F','T','F','T','F','T'}
    };
    NavMap navmap5 = new NavMap(map5);
    navmap5.registerEntity(entityMap.get("player"),8,7);
    navmap5.registerEntity(entityMap.get("rightLineEnemy"),4,8);
    navmap5.registerEntity(entityMap.get("leftLineEnemy"),8,1);
    manager.registerMap(navmap5); 
}

public void defineHudElements() {

}