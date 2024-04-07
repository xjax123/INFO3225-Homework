enum AnimationState {
    PAUSED,
    PLAYING,
    FINISHED,
    WAITING,
    BUFFER,
    PENDING
}

class Animation {
    KeyFrame[] kfs;
    int currentIndex = 0;
    public boolean looping;
    public boolean interuptable;
    public boolean forceInterupt;
    public EntFunction fin;
    float curTime = 0;
    float curRotX = 0;
    float curRotY = 0;
    float curRotZ = 0;
    PVector curTranslate = new PVector(0,0,0);
    KeyFrame prevFrame;
    KeyFrame targetFrame;
    public AnimationState state = AnimationState.WAITING;

    public Animation(KeyFrame[] _kfs, boolean _looping, boolean _interuptable, EntFunction con, MapEntitiy target) {
        kfs = _kfs;
        looping = _looping;
        prevFrame = new KeyFrame(curTime, curRotX, curRotY, curRotZ, curTranslate);
        targetFrame = kfs[currentIndex];
        fin = con;
        interuptable = _interuptable;
    }    
    public Animation(KeyFrame[] _kfs, boolean _looping, boolean _interuptable, EntFunction con, MapEntitiy target, boolean _forceInterupt) {
        kfs = _kfs;
        looping = _looping;
        prevFrame = new KeyFrame(curTime, curRotX, curRotY, curRotZ, curTranslate);
        targetFrame = kfs[currentIndex];
        fin = con;
        interuptable = _interuptable;
        forceInterupt = _forceInterupt;
    }
    public Animation(Animation a) {
        kfs = a.getKeyframes();
        looping = a.looping;
        curTime = 0;
        curRotX = 0;
        curRotY = 0;
        curRotZ = 0;
        curTranslate = new PVector(0,0,0);
        prevFrame = new KeyFrame(curTime, curRotX, curRotY, curRotZ, curTranslate);
        targetFrame = kfs[currentIndex];
        fin = a.fin;
        interuptable = a.interuptable;
        state = AnimationState.WAITING;
    }

    public KeyFrame[] getKeyframes() {
        return kfs;
    }

    public KeyFrame getCurrentKeyframe() {
        return kfs[currentIndex];
    }

    public int getCurrentIndex() {
        return currentIndex;
    }

    public EntFunction getFinishFunction() {
        return fin;
    }

    public void play() {
        state = AnimationState.PLAYING;
    }

    public void pause() {
        state = AnimationState.PAUSED;
    }

    public void unpause() {
        state = AnimationState.PLAYING;
    }

    public void step(PGraphics buffer, MapEntitiy ent) {
        if (state == AnimationState.FINISHED || state == AnimationState.PAUSED || state == AnimationState.WAITING) {
            return;
        }

        if (curTime >= targetFrame.time) {
            if (currentIndex+1 < kfs.length) {
                curTime = 0;
                currentIndex +=1;
                prevFrame = targetFrame;
                targetFrame = kfs[currentIndex];
            } else {
                if (looping == true) {
                    curTime = 0;
                    currentIndex = 0;
                    curTime = 0;
                    curRotX = 0;
                    curRotY = 0;
                    curRotZ = 0;
                    curTranslate = new PVector(0,0,0);
                    prevFrame = new KeyFrame(curTime, curRotX, curRotY, curRotZ, curTranslate);
                    targetFrame = kfs[currentIndex];
                } else if (state == AnimationState.PLAYING) {
                    onFinish(ent);
                }
            }
        }

        float comPer = animNormalize(curTime,0,targetFrame.time);
        curRotX = prevFrame.rotX + (targetFrame.rotX-prevFrame.rotX)*comPer;
        curRotY = prevFrame.rotY + (targetFrame.rotY-prevFrame.rotY)*comPer;
        curRotZ = prevFrame.rotZ + (targetFrame.rotZ-prevFrame.rotZ)*comPer;
        curTranslate.x = prevFrame.translate.x + (targetFrame.translate.x-prevFrame.translate.x)*comPer;
        curTranslate.y = prevFrame.translate.y + (targetFrame.translate.y-prevFrame.translate.y)*comPer;
        curTranslate.z = prevFrame.translate.z + (targetFrame.translate.z-prevFrame.translate.z)*comPer;
        buffer.translate(curTranslate.x,curTranslate.y,curTranslate.z);
        buffer.rotateX(radians(curRotX));
        buffer.rotateY(radians(curRotY));
        buffer.rotateZ(radians(curRotZ));
        
        curTime += 1;
    }

    public void onFinish(MapEntitiy ent) {
        functionManager.add(new ReferencedLamda(fin,ent,this));
    }

    @Override
    public String toString() {
        String temp = "[";
        for (KeyFrame k : kfs) {
            temp += k.toString();
            temp += ", ";
        }
        temp += "]";
        return temp;
    }
}

class KeyFrame {
    public float time;
    public float rotX;
    public float rotY;
    public float rotZ;
    public PVector translate;

    public KeyFrame(float _time, float _rotX, float _rotY, float _rotZ, PVector _translate) {
        time = _time;
        rotX = _rotX;
        rotY = _rotY;
        rotZ = _rotZ;
        translate = _translate;
    }

    @Override
    public String toString() {
        return "[t:"+time+", rotX: "+rotX+", rotY: "+rotY+", rotZ: "+rotZ+", translate: "+translate.toString()+"]";
    }
}

float animNormalize(float data, float min, float max) {
    return ((data-min)/(max-min));
}