public class PhysVector {
    private float x; //what direction its going vertically, normalized to between 1 and -1
    private float y; //what direction its going vertically, normalized to between 1 and -1
    private float velocity; //how fast its going, in M/s

    //create an empty vector
    public PhysVector() {
        x = 0;
        y = 0;
        velocity = 0;
    }
    //Create a Physvector from its component parts
    //x and y's absolute values should add up to equal roughly 1.0, otherwise this will potentially create strange behavior
    public PhysVector(float _x, float _y, float _velocity) {
        x = _x;
        y = _y;
        velocity = _velocity;
    }
    //create a PhysVector from a Pvector
    public PhysVector(PVector vec) {
        float tv = abs(vec.x)+abs(vec.y);
        velocity = tv;
        x = physNormalize(vec.x,-tv,tv);
        y = physNormalize(vec.y,-tv,tv);
    }

    //various useful getters
    public PVector totalSpeed() {
        return new PVector(velocity*x,velocity*y);
    }
    public float speedX() {
        return x*velocity;
    }
    public float speedY() {
        return y*velocity;
    }
    public float unitX() {
        return x;
    }
    public float unitY() {
        return y;
    }
    public float getVelocity() {
        return velocity;
    }
    public PVector unitVector() {
        return new PVector(x,y);
    }
    public float direction() {
        return degrees(atan2(x,y));
    }

    //Setters
    public void set(float _x, float _y, float _velocity) {
        x = _x;
        y = _y;
        velocity = _velocity;
    }
    public void setX(float _x) {
        x = _x;
    }
    public void setY(float _y) {
        y = _y;
    }
    public void setVelocity(float _velocity) {
        velocity = _velocity;
    }

    //Applying an impulse of force
    public void impulse(PVector v) {
        PVector total = this.totalSpeed();
        total.x = total.x+v.x;
        total.y = total.y+v.y;
        float tv = total.x+total.y;
        velocity = tv;
        x = physNormalize(total.x,-tv,tv);
        y = physNormalize(total.y,-tv,tv);
    }
    public void impulse(PhysVector v) {
        impulse(v.totalSpeed());
    }

    @Override
    public String toString() {
        return "[ X:"+this.x+", Y:"+this.y+", Velocity: "+this.velocity+"]";
    }
}