class SceneManager {
    ArrayList<NavMap> maps = new ArrayList<NavMap>();
    int mapIndex = 0;
    MapEntitiy mainChar;
    NavMap activeMap;
    public SceneManager() {}

    public void registerMap(NavMap map) {
        maps.add(map);
        if (activeMap == null) {
           setActiveMap(map);
        }
    }

    public NavMap getActiveMap() {
        return activeMap;
    }

    public MapEntitiy getPlayer() {
        return mainChar;
    }
    public void reload() {
        setActiveMap(maps.get(mapIndex));
    }

    public void nextScene() {
        if (mapIndex+1 >= maps.size()) {
            mapIndex = -1;
        }
        mapIndex += 1;
        setActiveMap(maps.get(mapIndex));
    }

    private void setActiveMap(NavMap map) {
        activeMap = new NavMap(map);
        mainChar = activeMap.getPlayer();
    }
}