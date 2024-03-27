import java.util.HashMap;

HashMap<Character, MapTile> tileMap = new HashMap<Character, MapTile>();
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
                    if (tile instanceof DangerTile) {
                        tiles[x][y] = new DangerTile(tile);
                    } else {
                        tiles[x][y] = new MapTile(tile);
                    }
                }
                if (map.entities[x][y] != null) {
                    if (map.entities[x][y] instanceof Player) {
                        entities[x][y] = new Player(map.entities[x][y]);
                    } else {
                        entities[x][y] = new MapEntitiy(map.entities[x][y]);
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
        entities = new MapEntitiy[_mapTiles.length][max];
        for (int x = 0; x < tiles.length; x++) {
            for (int y = 0; y < tiles[x].length; y++) {
                if (_mapTiles[x][y] == null) {
                    tiles[x][y] = new MapTile();
                } else {
                    MapTile tile = tileMap.get(_mapTiles[x][y]);
                    if (tile instanceof DangerTile) {
                        tiles[x][y] = new DangerTile(tile);
                    } else {
                        tiles[x][y] = new MapTile(tile);
                    }
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
    public void registerEntity(MapEntitiy ent) {
        entities[ent.mapX][ent.mapY] = ent;
        tiles[ent.mapX][ent.mapY].walkTile(ent);
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

    public void drawMap(PGraphics buffer) {
        main.pushMatrix();
            for (int x = 0; x < tiles.length; x++) {
                main.translate(50,0,0);
                main.pushMatrix();
                    for (int y = 0; y < tiles[x].length; y++) {
                        main.translate(0,0,50);
                        if (entities[x][y] != null) {
                            main.shape(entities[x][y].shape,0,0);
                        }
                        main.shape(tiles[x][y].shape,0,0);
                    }
                main.popMatrix();
            }
        main.popMatrix();
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
        ent.kill();
    }
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
    public EntState state;

    public MapEntitiy(MapEntitiy ent) {
        mapX = ent.mapX;
        mapY = ent.mapY;
        shape = ent.shape;
        state = ent.state;
        shape.setVisible(true);
    }
    public MapEntitiy(int _x, int _y, PShape _shape) {
        mapX = _x;
        mapY = _y;
        shape = _shape;
        state = EntState.ALIVE;
    }

    public void collide() {}

    public void kill() {
        state = EntState.DEAD;
        shape.setVisible(false);
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