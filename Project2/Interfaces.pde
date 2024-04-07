interface EntFunction {
    void run(MapEntitiy m);
}

class ReferencedLamda {
    EntFunction func;
    MapEntitiy ent;
    Animation a;

    public ReferencedLamda(EntFunction _func, MapEntitiy _ent, Animation _a) {
        func = _func;
        ent = _ent;
        a = _a;
    }

    void run() {
        func.run(ent);
        a.state = AnimationState.FINISHED;
    }
}