enum AnimationState {
    PAUSED,
    PLAYING,
    FINISHED,
    WAITING,
    BUFFER,
    PENDING
}

class Animation {
    String name;
    KeyFrame[] kfs;
    int currentIndex = 0;
    public boolean looping;
    public boolean interuptable;
    public boolean moving; 
    public boolean forceInterupt;
    public EntFunction fin;
    public EntFunction start;
    float totalTime = 0;
    float elapsedTime = 0;
    float curTime = 0;
    float curRotX = 0;
    float curRotY = 0;
    float curRotZ = 0;
    float curScale = 1;
    PVector curTranslate = new PVector(0,0,0);
    KeyFrame prevFrame;
    KeyFrame targetFrame;
    public AnimationState state = AnimationState.WAITING;
    public Animation(String _name, KeyFrame[] _kfs, boolean _looping, boolean _interuptable, boolean _moving, EntFunction _start, EntFunction end) {
        name = _name;
        kfs = _kfs;
        looping = _looping;
        prevFrame = new KeyFrame(curTime, curRotX, curRotY, curRotZ, curScale, curTranslate);
        targetFrame = kfs[currentIndex];
        fin = end;
        start = _start;
        interuptable = _interuptable;
        moving = _moving;
        for (KeyFrame k : kfs) {
            totalTime += k.time;
        }
    }    
    public Animation(String _name, KeyFrame[] _kfs, boolean _looping, boolean _interuptable, boolean _moving, EntFunction _start, EntFunction end, boolean _forceInterupt) {
        name = _name;
        kfs = _kfs;
        looping = _looping;
        prevFrame = new KeyFrame(curTime, curRotX, curRotY, curRotZ, curScale, curTranslate);
        targetFrame = kfs[currentIndex];
        fin = end;
        start = _start;
        interuptable = _interuptable;
        moving = _moving;
        forceInterupt = _forceInterupt;
        for (KeyFrame k : kfs) {
            totalTime += k.time;
        }
    }
    public Animation(Animation a) {
        name = a.name;
        kfs = a.getKeyframes();
        looping = a.looping;
        curTime = 0;
        curRotX = 0;
        curRotY = 0;
        curRotZ = 0;
        curScale = 1;
        curTranslate = new PVector(0,0,0);
        prevFrame = new KeyFrame(curTime, curRotX, curRotY, curRotZ, curScale, curTranslate);
        targetFrame = kfs[currentIndex];
        fin = a.fin;
        start = a.start;
        interuptable = a.interuptable;
        moving = a.moving;
        state = AnimationState.WAITING;
        totalTime = a.totalTime;
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

    public float getPerFinished() {
        return animNormalize(elapsedTime,0,totalTime);
    }

    public void play(MapEntitiy ent) {
        functionManager.add(new ReferencedLamda(start,ent,this,LambdaType.START));
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
                    curScale = 1;
                    curTranslate = new PVector(0,0,0);
                    prevFrame = new KeyFrame(curTime, curRotX, curRotY, curRotZ, curScale, curTranslate);
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
        curScale = prevFrame.scale + (targetFrame.scale-prevFrame.scale)*comPer;
        buffer.scale(curScale);
        buffer.translate(curTranslate.x,curTranslate.y,curTranslate.z);
        buffer.rotateX(radians(curRotX));
        buffer.rotateY(radians(curRotY));
        buffer.rotateZ(radians(curRotZ));
        
        curTime += 1;
        elapsedTime += 1;
    }

    public void onFinish(MapEntitiy ent) {
        functionManager.add(new ReferencedLamda(fin,ent,this,LambdaType.FINISH));
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
    public float scale;
    public PVector translate;

    public KeyFrame(float _time, float _rotX, float _rotY, float _rotZ, float _scale, PVector _translate) {
        time = _time;
        rotX = _rotX;
        rotY = _rotY;
        rotZ = _rotZ;
        scale = _scale;
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