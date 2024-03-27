class Animation {
    KeyFrame root;
    KeyFrame current;
    boolean looping;
}

class KeyFrame {
    public float time;
    public float rotX;
    public float rotY;
    public float rotZ;
    public PVector translate;

    public KeyFrame next;
    public KeyFrame prev;
}