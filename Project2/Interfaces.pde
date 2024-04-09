interface EntFunction {
    void run(MapEntitiy m);
}

interface UIFunction {
    void run();
}

enum LambdaType {
    START,
    FINISH
}

class ReferencedLamda {
    EntFunction func;
    MapEntitiy ent;
    Animation a;
    LambdaType type;

    public ReferencedLamda(EntFunction _func, MapEntitiy _ent, Animation _a, LambdaType _type) {
        func = _func;
        ent = _ent;
        a = _a;
        type = _type;
    }

    void run() {
        func.run(ent);
        if (type == LambdaType.START) {
            a.state = AnimationState.PLAYING;
        } else if (type == LambdaType.FINISH) {
            a.state = AnimationState.FINISHED;
        }
    }
}