import java.util.HashMap;

HashMap<Character, MapTile> tileMap = new HashMap<Character, MapTile>();
HashMap<String, MapEntitiy> entityMap = new HashMap<String, MapEntitiy>();
enum Direction {
    UP,
    DOWN,
    LEFT,
    RIGHT
};

class NavMap {
    MapTile[][] tiles;
    MapEntitiy[][] entities;

    public NavMap(NavMap map) {
        tiles = new MapTile[map.tiles.length][map.tiles[0].length];
        entities = new MapEntitiy[map.tiles.length][map.tiles[0].length];
        for (int x = 0; x < tiles.length; x++) {
            for (int y = 0; y < tiles[x].length; y++) {
                if (map.tiles[x][y] == null) {
                    tiles[x][y] = new MapTile();
                } else {
                    MapTile tile = map.tiles[x][y];
                    tiles[x][y] = tileCopy(tile);
                }
                if (map.entities[x][y] != null) {
                    entities[x][y] = entityCopy(map.entities[x][y]);
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
        entities = new MapEntitiy[_mapTiles.length][max];
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
                if (entities[x][y] instanceof Player) {
                    return entities[x][y];
                }
            }
        }
        return null;
    }
    public void registerEntity(MapEntitiy ent, int x, int y) {
        entities[x][y] = entityCopy(ent);
        entities[x][y].mapX = x;
        entities[x][y].mapY = y;
        tiles[x][y].walkTile(ent);
    }

    public void positionEnt(MapEntitiy ent, int newX, int newY) {
        int prevX = ent.mapX;
        int prevY = ent.mapY;
        entities[newX][newY] = ent;
        ent.mapX = newX;
        ent.mapY = newY;
        entities[prevX][prevY] = null;
    }
    //remember to update to include collision detection
    public void moveEnt(MapEntitiy ent, Direction d) {
        if (ent.state == EntState.DEAD) {
            return;
        }

        if (d == Direction.UP) {
            int newY = ent.mapY-1;
            if (inBounds(ent.mapX,newY)) {
                if (tiles[ent.mapX][newY].walkable) {
                    tiles[ent.mapX][newY].walkTile(ent);
                    positionEnt(ent,ent.mapX,newY);
                }
            }
        } else if (d == Direction.DOWN) {
            int newY = ent.mapY+1;
            if (inBounds(ent.mapX,newY)) {
                if (tiles[ent.mapX][newY].walkable) {
                    tiles[ent.mapX][newY].walkTile(ent);
                    positionEnt(ent,ent.mapX,newY);
                }       
            }
        } else if (d == Direction.LEFT) {
            int newX = ent.mapX-1;
            if (inBounds(newX,ent.mapY)) {
                if (tiles[newX][ent.mapY].walkable) {
                    tiles[newX][ent.mapY].walkTile(ent);
                    positionEnt(ent,newX,ent.mapY);
                }
            }
        } else if (d == Direction.RIGHT) {
            int newX = ent.mapX+1;
            if (inBounds(newX,ent.mapY)) {
                if (tiles[newX][ent.mapY].walkable) {
                    tiles[newX][ent.mapY].walkTile(ent);
                    positionEnt(ent,newX,ent.mapY);
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
                if (tiles[ent.mapX][newY].walkable) {
                    return true;
                }
            }
        } else if (d == Direction.DOWN) {
            int newY = ent.mapY+1;
            if (inBounds(ent.mapX,newY)) {
                if (tiles[ent.mapX][newY].walkable) {
                    return true;
                }       
            }
        } else if (d == Direction.LEFT) {
            int newX = ent.mapX-1;
            if (inBounds(newX,ent.mapY)) {
                if (tiles[newX][ent.mapY].walkable) {
                    return true;
                }
            }
        } else if (d == Direction.RIGHT) {
            int newX = ent.mapX+1;
            if (inBounds(newX,ent.mapY)) {
                if (tiles[newX][ent.mapY].walkable) {
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
                        if (entities[x][y] != null) {
                            if (entities[x][y].visible) {
                                buffer.pushMatrix();
                                entities[x][y].animate(buffer);
                                entities[x][y].draw(buffer);
                                buffer.popMatrix();
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

    public void walkTile(MapEntitiy ent) {
        devText = "Walking on - "+identifier.toString();
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

    @Override
    public void walkTile(MapEntitiy ent) {
        super.walkTile(ent);
        try {
            ent.playAnimation("lavaDeath");
        } catch (Exception e) {
            println(e.toString());
        }
    }
}
class WinTile extends MapTile {
    public WinTile(MapTile copy) {
        super(copy);
    }
    public WinTile(Character id, PShape _shape) {
        super(id,_shape,true);
    }

    @Override
    public void walkTile(MapEntitiy ent) {
        super.walkTile(ent);
        manager.nextScene();
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
    public int mapY;
    public PShape shape;
    public EntState state = EntState.ALIVE;
    public boolean visible = true;
    public HashMap<String, Animation> animations = new HashMap<String, Animation>();
    public Animation activeAnimation = null;

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

    public void collide() {}

    public void kill() {
        state = EntState.DEAD;
        visible = false;
    }

    public void playAnimation(String t) throws Exception {
        Animation a = animations.get(t);
        if (activeAnimation != null && !a.forceInterupt) {
            if (!activeAnimation.interuptable && !(activeAnimation.state == AnimationState.FINISHED)) {
                return;
            }
        }
        if (a == null) {
            throw new Exception("Error: Tried To Invoke Animation That Does Not Exit.");
        }
        activeAnimation = new Animation(a);
        activeAnimation.play();
    }    
    public void registerAnimation(String t, Animation a) {
        animations.put(t,a);
    }

    public void draw(PGraphics buffer) {
        buffer.shape(shape,0,0);
    }

    public void animate(PGraphics buffer) {
        if (activeAnimation != null) {
            if (activeAnimation.state != AnimationState.FINISHED) {
                activeAnimation.step(buffer, this);
            }
        }
    }
}

class Player extends MapEntitiy{
    public Player(MapEntitiy ent) {
        super(ent);
    }
    public Player(int _x, int _y, PShape _shape) {
        super(_x,_y,_shape);
    }
}

public MapEntitiy entityCopy(MapEntitiy ent) {
    MapEntitiy me;
    if (ent instanceof Player) {
        me = new Player(ent);
    } else {
        me = new MapEntitiy(ent);
    }
    return me;
}