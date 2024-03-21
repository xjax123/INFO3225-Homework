//normalizes to between 1 and -1
float physNormalize(float data, float min, float max) {
    return (2*(data-min)/(max-min))-1;
}

float distance(float x1, float y1, float x2, float y2) {
    return (float) Math.sqrt(Math.pow(x2-x1,2)+Math.pow(y2-y1,2));
}

float vecDot(PVector v1, PVector v2) {
    float x = v1.x*v2.x;
    float y = v1.y*v2.y;
    return x+y;
}
PVector vecAdd(PVector v1, PVector v2) {
    return new PVector(v1.x+v2.x,v1.y+v2.y);
}
PVector vecSub(PVector v1, PVector v2) {
    return new PVector(v1.x-v2.x,v1.y-v2.y);
}
PVector vecMulti(PVector v1, PVector v2) {
    return new PVector(v1.x*v2.x,v1.y*v2.y);
}
PVector vecDiv(PVector v1, PVector v2) {
    return new PVector(v1.x/v2.x,v1.y/v2.y);
}
PVector vecScalarAdd(PVector v, float s) {
    return new PVector(v.x+s,v.y+s);
}
PVector vecScalarSub(PVector v, float s) {
    return new PVector(v.x-s,v.y-s);
}
PVector vecScalarMulti(PVector v, float s) {
    return new PVector(v.x*s,v.y*s);
}
PVector vecScalarDiv(PVector v, float s) {
    return new PVector(v.x/s,v.y/s);
}
PVector vecPow (PVector v, float power) {
    return new PVector((float) Math.pow(v.x,power), (float) Math.pow(v.y,power));
}