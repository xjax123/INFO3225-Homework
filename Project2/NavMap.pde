import java.util.HashMap;

HashMap<Character, MapTile> tileMap = new HashMap<Character, MapTile>();
HashMap<String, MapEntitiy> entityMap = new HashMap<String, MapEntitiy>();

enum Direction {
    UP,
    DOWN,
    LEFT,
    RIGHT
};

enum AIState {
    WAITING,
    ACTING
}

class NavMap {
    MapTile[][] tiles;
    ArrayList<MapEntitiy> entities = new ArrayList<MapEntitiy>();;

    public NavMap(NavMap map) {
        tiles = new MapTile[map.tiles.length][map.tiles[0].length];
        for (int x = 0; x < tiles.length; x++) {
            for (int y = 0; y < tiles[x].length; y++) {
                if (map.tiles[x][y] == null) {
                    tiles[x][y] = new MapTile();
                } else {
                    MapTile tile = map.tiles[x][y];
                    tiles[x][y] = tileCopy(tile);
                }
                if (map.entities != null) {
                    ArrayList<MapEntitiy> ents = map.getEnts(x,y);
                    for (MapEntitiy ent : ents) {
                        entities.add(entityCopy(ent));
                    }
                }
            }
        }
    }

    public NavMap(Character[][] _mapTiles) {
        int max = 0;
        for (int i = 0; i < _mapTiles.length; i++) {
            if (_mapTiles[i].length > max) {
                max = _mapTiles[i].length;
            }
        }
        tiles = new MapTile[_mapTiles.length][max];
        for (int x = 0; x < tiles.length; x++) {
            for (int y = 0; y < tiles[x].length; y++) {
                if (_mapTiles[x][y] == null || _mapTiles[x][y] == 'b') {
                    tiles[x][y] = new MapTile();
                } else {
                    MapTile tile = tileMap.get(_mapTiles[x][y]);
                    tiles[x][y] = tileCopy(tile);
                }
            }
        }
    }

    public boolean inBounds(int x, int y) {
        if (x >= 0 && x < tiles.length) {
            if (y >= 0 && y < tiles[0].length) {
                return true;
            }
        }
        return false;
    }

    public MapEntitiy getPlayer() {
        for (int x = 0; x < tiles.length; x++) {
            for (int y = 0; y < tiles[x].length; y++) {
                ArrayList<MapEntitiy> ents = getEnts(x,y);
                for (MapEntitiy ent : ents) {
                    if (ent instanceof Player) {
                        return ent;
                    }
                }
            }
        }
        return null;
    }

    public ArrayList<MapEntitiy> getEnts(int x, int y) {
        ArrayList<MapEntitiy> map = new ArrayList<MapEntitiy>();
        for (MapEntitiy ent : entities) {
            if (ent.mapX == x) {
                if (ent.mapY == y) {
                    map.add(ent);
                }
            }
        }
        return map;
    }
    public void registerEntity(MapEntitiy ent, int x, int y) {
        MapEntitiy newEnt = entityCopy(ent);
        entities.add(newEnt);
        newEnt.mapX = x;
        newEnt.mapY = y;
        newEnt.walkTile(tiles[x][y]);
    }

    public void positionEnt(MapEntitiy ent, int newX, int newY) {
        ent.mapX = newX;
        ent.mapY = newY;
    }
    //remember to update to include collision detection
    public void moveEnt(MapEntitiy ent, Direction d) {
        if (ent.state == EntState.DEAD) {
            return;
        }
        int x = ent.mapX;
        int y = ent.mapY;
        if (d == Direction.UP) {
            int newY = y-1;
            if (inBounds(x,newY)) {
                if (ent.canWalk(tiles[x][newY])) {
                    ent.walkTile(tiles[x][newY]);
                    positionEnt(ent,x,newY);
                }
            }
        } else if (d == Direction.DOWN) {
            int newY = y+1;
            if (inBounds(x,newY)) {
                if (ent.canWalk(tiles[x][newY])) {
                    ent.walkTile(tiles[x][newY]);
                    positionEnt(ent,x,newY);
                }       
            }
        } else if (d == Direction.LEFT) {
            int newX = x-1;
            if (inBounds(newX,y)) {
                if (ent.canWalk(tiles[newX][y])) {
                    ent.walkTile(tiles[newX][y]);
                    positionEnt(ent,newX,y);
                }
            }
        } else if (d == Direction.RIGHT) {
            int newX = x+1;
            if (inBounds(newX,y)) {
                if (ent.canWalk(tiles[newX][y])) {
                    ent.walkTile(tiles[newX][y]);
                    positionEnt(ent,newX,y);
                }
            }
        }
    }

    public boolean checkEnt(MapEntitiy ent, Direction d) {
        if (ent.state == EntState.DEAD) {
            return false;
        }

        if (d == Direction.UP) {
            int newY = ent.mapY-1;
            if (inBounds(ent.mapX,newY)) {
                if (ent.canWalk(tiles[ent.mapX][newY])) {
                    return true;
                }
            }
        } else if (d == Direction.DOWN) {
            int newY = ent.mapY+1;
            if (inBounds(ent.mapX,newY)) {
                if (ent.canWalk(tiles[ent.mapX][newY])) {
                    return true;
                }       
            }
        } else if (d == Direction.LEFT) {
            int newX = ent.mapX-1;
            if (inBounds(newX,ent.mapY)) {
                if (ent.canWalk(tiles[newX][ent.mapY])) {
                    return true;
                }
            }
        } else if (d == Direction.RIGHT) {
            int newX = ent.mapX+1;
            if (inBounds(newX,ent.mapY)) {
                if (ent.canWalk(tiles[newX][ent.mapY])) {
                    return true;
                }
            }
        }
        return false;
    }

    public void drawMap(PGraphics buffer) {
        buffer.pushMatrix();
            for (int x = 0; x < tiles.length; x++) {
                buffer.translate(50,0,0);
                buffer.pushMatrix();
                    for (int y = 0; y < tiles[x].length; y++) {
                        buffer.translate(0,0,50);
                        ArrayList<MapEntitiy> ents = getEnts(x,y);
                        for (MapEntitiy ent : ents) {
                            if (ent != null) {
                                if (ent.visible) {
                                    aiCall(ent);
                                    buffer.pushMatrix();
                                    ent.animate(buffer);
                                    ent.draw(buffer);
                                    buffer.popMatrix();
                                }
                            }
                        }
                        if (tiles[x][y].visible) {
                            buffer.shape(tiles[x][y].shape,0,0);
                        }
                    }
                buffer.popMatrix();
            }
        buffer.popMatrix();
    }

    @Override
    public String toString() {
        String smap = "";
        smap += "[";
        for (int x = 0; x < tiles.length; x++) {
            smap += "{";
            for (int y = 0; y < tiles[x].length; y++) {
                smap += tiles[x][y].toString();
            }
            smap += "}";
        }
        smap += "]";
        return smap;
    }
}

//Tile Classes & Utils
class MapTile {
    public Character identifier;
    public PShape shape = createShape();
    public boolean walkable = false;
    public boolean visible = true;

    public MapTile() {
        identifier = 'b';
    }
    public MapTile(MapTile copy) {
        identifier = copy.identifier;
        shape = copy.shape;
        walkable = copy.walkable;
    }
    public MapTile(Character id, PShape _shape) {
        identifier = id;
        shape = _shape;
    }
    public MapTile(Character id, PShape _shape, boolean _walkable) {
        identifier = id;
        shape = _shape;
        walkable = _walkable;
    }

    public void setVisible(boolean b) {
        visible = b;
    }

    @Override
    public String toString() {
        return identifier.toString();
    }
}

class DangerTile extends MapTile {
    public DangerTile(MapTile copy) {
        super(copy);
    }
    public DangerTile(Character id, PShape _shape) {
        super(id,_shape,true);
    }
}
class WinTile extends MapTile {
    public WinTile(MapTile copy) {
        super(copy);
    }
    public WinTile(Character id, PShape _shape) {
        super(id,_shape,true);
    }
}

public MapTile tileCopy(MapTile tile) {
    MapTile mt;
    if (tile instanceof DangerTile) {
        mt = new DangerTile(tile);
    } else if (tile instanceof WinTile) {
        mt = new WinTile(tile);
    } else {
        mt = new MapTile(tile);
    }
    return mt;
}

//Entity Classes & Utils
enum EntState {
    ALIVE,
    DEAD
}

class MapEntitiy {
    public int mapX;
    public int intendedX;
    public int mapY;
    public int intendedY;
    public PShape shape;
    public EntState state = EntState.ALIVE;
    public boolean visible = true;
    public HashMap<String, Animation> animations = new HashMap<String, Animation>();
    public ArrayList<Animation> activeAnimations = new ArrayList<Animation>();

    public MapEntitiy(MapEntitiy ent) {
        mapX = ent.mapX;
        mapY = ent.mapY;
        shape = ent.shape;
        state = ent.state;
        visible = ent.visible;
        animations = ent.animations;
    }
    public MapEntitiy(int _x, int _y, PShape _shape) {
        mapX = _x;
        mapY = _y;
        shape = _shape;
    }

    public boolean canWalk(MapTile tile) {
        if (tile.walkable) {
            return true;
        } else {
            return false;
        }
    }

    public void walkTile(MapTile tile) {}

    public void checkColide(int x, int y) {
        ArrayList<MapEntitiy> ents = manager.getActiveMap().getEnts(x,y);
        for (MapEntitiy ent : ents) {
            if (ent == this) {
                break;
            }
            if (ent.activeAnimations.size() == 0 || ent.activeAnimations.get(0).state == AnimationState.FINISHED || !ent.activeAnimations.get(0).moving) { 
                if (ent.mapX == x && ent.mapY == y) {
                    collide(ent);
                }
            } else if (ent.activeAnimations.get(0).getPerFinished() < 0.2) {
                if (ent.intendedX == x && ent.intendedY == y) {
                    collide(ent);
                } else if (ent.mapX == x && ent.mapY == y) {
                    collide(ent);
                }
            }
        }
    }

    public void collide(MapEntitiy ent) {}

    public void kill() {
        state = EntState.DEAD;
        visible = false;
    }

    public void playAnimation(String t) throws Exception {
        Animation a = animations.get(t);
        for (Animation activeAnimation : activeAnimations) {
            if (activeAnimation.state != AnimationState.FINISHED) {
                if (!a.forceInterupt && !activeAnimation.interuptable) {
                    return;
                }
                if (activeAnimation.name == a.name) {
                    return;
                }
            }
        }
        if (a == null) {
            throw new Exception("Error: Tried To Invoke Animation That Does Not Exit.");
        }
        println("Finihsed Checks");
        Animation anim = new Animation(a);
        activeAnimations.add(anim);
        anim.play(this);
    }    
    public void registerAnimation(String t, Animation a) {
        animations.put(t,a);
    }

    public void draw(PGraphics buffer) {
        buffer.shape(shape,0,0);
    }

    public void animate(PGraphics buffer) {
        for (Animation activeAnimation : activeAnimations) {
            if (activeAnimation.state != AnimationState.FINISHED) {
                activeAnimation.step(buffer, this);
            }
        }
        int size = activeAnimations.size();
        for (int x = 0; x < size-1; x++) {
            Animation a = activeAnimations.get(x);
            if (a.state == AnimationState.FINISHED) {
                activeAnimations.remove(a);
            }
        }
    }
}

class Player extends MapEntitiy {
    public Player(Player ent) {
        super(ent);
    }
    public Player(int _x, int _y, PShape _shape) {
        super(_x,_y,_shape);
    }

    @Override
    public void collide(MapEntitiy ent) {
        try {
            playAnimation("normalDeath");
        } catch (Exception e) {
            println(e.toString());
        }
    }

    @Override
    public void walkTile(MapTile tile) {
        super.walkTile(tile);
        devText = "Walking on - "+tile.identifier.toString();
        if (tile instanceof DangerTile) {
            try {
                playAnimation("lavaDeath");
            } catch (Exception e) {
                println(e.toString());
            }
        }
        if (tile instanceof WinTile) {
            manager.nextScene();
        }
    }
}

class AIEntity extends MapEntitiy {
    public int moveFreq = 1;
    public int step = 0;
    AIState ai = AIState.WAITING;

    public AIEntity(AIEntity ent) {
        super(ent);
        moveFreq = ent.moveFreq;
        ai = AIState.WAITING;
    }
    
    public AIEntity(int _x, int _y, PShape _shape, int freq) {
        super(_x,_y,_shape);
        moveFreq = freq;
        ai = AIState.WAITING;
    }

    public void stepAI() {}
}

class LineEnemy extends AIEntity {
    Direction dir;
    public LineEnemy(LineEnemy ent) {
        super(ent);
        dir = ent.dir;
    }
    
    public LineEnemy(int _x, int _y, PShape _shape, int freq, Direction d) {
        super(_x,_y,_shape, freq);
        dir = d;
    }

    @Override
    public void collide(MapEntitiy ent) {
        if (ent == this) {
            return;
        }

        if (ent instanceof Player) {
            try{
                ent.playAnimation("normalDeath");
            } catch (Exception e) {
                println(e.toString());
            }
        } else {
            try{
                playAnimation("turnAround");
            } catch (Exception e) {
                println(e.toString());
            }
        }
    }

    @Override
    public void stepAI() {
        if (ai == AIState.WAITING) {
            if (step == moveFreq) {
                step = 0;
                ai = AIState.ACTING;
                if (manager.getActiveMap().checkEnt(this, dir)) {
                    try {
                        if (dir == Direction.UP) {
                            playAnimation("walkUp");
                        } else if (dir == Direction.DOWN) {
                            playAnimation("walkDown");
                        } else if (dir == Direction.LEFT) {
                            playAnimation("walkLeft");
                        } else if (dir == Direction.RIGHT) {
                            playAnimation("walkRight");
                        } 
                    } catch (Exception e) {
                        println(e.toString());
                    }
                } else {
                    try {
                        playAnimation("turnAround");
                    } catch (Exception e) {
                        println(e.toString());
                    }
                }
            } else {
                try {
                    playAnimation("idle");
                    ai = AIState.ACTING;
                } catch (Exception e) {
                    println(e.toString());
                }
            }
            step += 1;
        }
    }

}

public MapEntitiy entityCopy(MapEntitiy ent) {
    MapEntitiy me;
    if (ent instanceof Player) {
        me = new Player((Player) ent);
    } else if (ent instanceof LineEnemy) {
        me = new LineEnemy((LineEnemy) ent);
    } else if (ent instanceof AIEntity) {
        me = new AIEntity((AIEntity) ent);
    } else {
        me = new MapEntitiy(ent);
    }
    return me;
}

public void aiCall(MapEntitiy ent) {
    if (ent instanceof LineEnemy) {
        LineEnemy a = (LineEnemy) ent;
        a.stepAI();
    }
}