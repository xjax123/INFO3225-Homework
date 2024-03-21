public class AABB {
    public float minx, maxx, miny, maxy;

    public AABB(float _minx, float _maxx, float _miny, float _maxy) {
        minx = _minx;
        maxx = _maxx;
        miny = _miny;
        maxy = _maxy;
    }
}

public abstract class PhysicsBody {
    protected float mass;
    protected float elasticity = 1; //should be from 0 [Completely Inelastic] to 1 [Completely Elastic], retains that much of its total energy each collision.
    protected PVector position;
    protected AABB axisBox;
    protected AABB nextAxisBox;
    protected PhysVector vector;
    protected PVector nextPos;
    protected boolean gravity = true;
    protected ArrayList<PhysicsBody> colls = new ArrayList<PhysicsBody>();
    

    public PhysicsBody(float _mass, PVector _position) {
        mass = _mass;
        position = _position;
        vector = new PhysVector();
    }
    public PhysicsBody(float _mass, PVector _position, PhysVector _vector) {
        mass = _mass;
        position = _position;
        vector = _vector;
    }
    public PhysicsBody(float _mass, float _elasticity, PVector _position) {
        mass = _mass;
        position = _position;
        elasticity = _elasticity;
        vector = new PhysVector();
    }
    public PhysicsBody(float _mass, float _elasticity, PVector _position, PhysVector _vector) {
        mass = _mass;
        position = _position;
        elasticity = _elasticity;
        vector = _vector;
    }

    //Geters
    public PVector getPosition() {
        return position;
    }
    public PhysVector getVector() {
        return vector;
    }
    public float getMass() {
        return mass;
    }
    public PVector getNextPos() {
        return nextPos;
    }
    public boolean gravityAffected() {
        return gravity;
    }

    //Seters
    public void move(PVector v) {
        position = v;
        calcAABB();
    }
    public void setVector(PhysVector v) {
        vector = v;
    }
    public void setNextPos(PVector v) {
        nextPos = v;
    }
    public void setGravityMode(boolean b) {
        gravity = b;
    }

    public void startstep(float freq, float scale) {
        PVector tv = vector.totalSpeed();
        tv.x = (tv.x*scale)/freq;
        tv.y = (tv.y*scale)/freq;
        nextPos = new PVector(0,0);
        nextPos.x = position.x+tv.x;
        nextPos.y = position.y+tv.y;
        calcNextAABB();
    }
    public void endstep() {
        move(new PVector(nextPos.x,nextPos.y));
    }

    public void impulse(PVector v) {
        vector.impulse(v);
    }
    public void impulse(PhysVector v) {
        vector.impulse(v);
    }
    public abstract void draw();
    public abstract void calcAABB();
    public abstract void calcNextAABB();
    public abstract void checkCollision(ArrayList<PhysicsBody> actors, PVector bound1, PVector bound2, float freq, float scale);
}

public class PhysicsCircle extends PhysicsBody {
    private float radius;
    private color col = color(0);

    public PhysicsCircle(float _mass, PVector _position, float _radius) {
        super(_mass,_position);
        radius = _radius;
        calcAABB();
        nextPos = position;
        calcNextAABB();
    }
    public PhysicsCircle(float _mass, PVector _position, PhysVector _vector, float _radius) {
        super(_mass,_position, _vector);
        radius = _radius;
        calcAABB();
        nextPos = position;
        calcNextAABB();
    }
    public PhysicsCircle(float _mass, float _elasticity, PVector _position, float _radius) {
        super(_mass,_elasticity,_position);
        radius = _radius;
        calcAABB();
        nextPos = position;
        calcNextAABB();
    }
    public PhysicsCircle(float _mass, float _elasticity, PVector _position, PhysVector _vector, float _radius) {
        super(_mass,_elasticity,_position, _vector);
        radius = _radius;
        calcAABB();
        nextPos = position;
        calcNextAABB();
    }

    @Override
    public void checkCollision(ArrayList<PhysicsBody> actors, PVector bound1, PVector bound2, float freq, float scale) {
        for(PhysicsBody actor : actors) {
            if (this == actor) {
                continue;
            }
            if (nextAxisBox.maxx >= actor.nextAxisBox.minx && actor.nextAxisBox.maxx >= nextAxisBox.minx && nextAxisBox.maxy >= actor.nextAxisBox.miny && actor.nextAxisBox.maxy >= nextAxisBox.miny) {
                if (actor instanceof PhysicsCircle) {
                    PhysicsCircle circle = (PhysicsCircle) actor;
                    float colDist = radius+circle.radius;
                    float dist = distance(nextPos.x,nextPos.y,actor.nextPos.x,actor.nextPos.y);
                    //something here is causing "stickiness" with other objects
                    if (dist <= colDist) {
                        collide(circle,freq,scale);
                    }
                }
            } 
        }
        if (nextPos.x-radius < bound1.x) {
            float unx = vector.unitX()*-1;
            float vel = vector.getVelocity();
            vector.setVelocity(vel*elasticity);
            vector.setX(unx);
            nextPos.x = bound1.x+radius;
        }
        if (nextPos.x+radius > bound2.x) {
            float unx = vector.unitX()*-1;
            float vel = vector.getVelocity();
            vector.setVelocity(vel*elasticity);
            vector.setX(unx);
            nextPos.x = bound2.x-radius;
        }
        if (nextPos.y-radius < bound1.y) {
            float uny = vector.unitY()*-1;
            float vel = vector.getVelocity();
            vector.setVelocity(vel*elasticity);
            vector.setY(uny);
            nextPos.y = bound1.y+radius;
        }
        if (nextPos.y+radius > bound2.y) {
            float uny = vector.unitY()*-1;
            float vel = vector.getVelocity();
            vector.setVelocity(vel*elasticity);
            vector.setY(uny);
            nextPos.y = bound2.y-radius;
        }
    }

    //collisions fucking suck
    public void collide(PhysicsBody b, float freq, float scale) {
        PVector tv = vector.totalSpeed();
        PVector otv = b.getVector().totalSpeed();
        float contactAngle = degrees(atan2(nextPos.x-b.nextPos.x,nextPos.y-b.nextPos.y)); //I think this is accurate, hopefully.
        float vx1 = tv.x;
        float vx2 = otv.x;
        float vy1 = tv.y;
        float vy2 = otv.y;
        float d1 = vector.direction();
        float d2 = b.getVector().direction();
        float m1 = mass;
        float m2 = b.getMass();
        //im pretty sure this equason is leaking velocity, but the fixed version is doing better.
        //objects are still unnaturally "Sticky" and will clump together.
        float fx = ((vx1*cos(d1-contactAngle)*(m1-m2)+(2*m2*vx2)*cos(d2-contactAngle))/(m1+m2))*cos(contactAngle)+vx1*sin(d1-contactAngle)*cos(contactAngle+(PI/2));
        float fy = ((vy1*cos(d1-contactAngle)*(m1-m2)+(2*m2*vy2)*cos(d2-contactAngle))/(m1+m2))*sin(contactAngle)+vy1*sin(d1-contactAngle)*sin(contactAngle+(PI/2)); 
        vector = new PhysVector(new PVector(fx,fy));
    }
    float buffer = 4;
    public void calcAABB() {
        axisBox = new AABB(position.x-radius-buffer,position.x+radius+buffer,position.y-radius-buffer,position.y+radius+buffer);
    }
    public void calcNextAABB() {
        nextAxisBox = new AABB(nextPos.x-radius-buffer,nextPos.x+radius+buffer,nextPos.y-radius-buffer,nextPos.y+radius+buffer);
    }

    public void draw(){
        fill(col);
        circle(position.x, position.y, radius*2);
        if (devmode == true) {
            noFill();
            beginShape();
            vertex(axisBox.minx,axisBox.miny);
            vertex(axisBox.maxx,axisBox.miny);
            vertex(axisBox.maxx,axisBox.maxy);
            vertex(axisBox.minx,axisBox.maxy);
            endShape(CLOSE);
            beginShape();
            vertex(nextAxisBox.minx,nextAxisBox.miny);
            vertex(nextAxisBox.maxx,nextAxisBox.miny);
            vertex(nextAxisBox.maxx,nextAxisBox.maxy);
            vertex(nextAxisBox.minx,nextAxisBox.maxy);
            endShape(CLOSE);
        }
    }
}