import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class SimulationController {
    private Simulation activeSim;
    private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
    ScheduledFuture<?> simHandler;

    public SimulationController() {}

    private final Runnable sim = new Runnable() {
        public void run() {
            try {
                activeSim.step();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    public void startEmptySim(PVector bound1, PVector bound2, float simFreq) {
        activeSim = new Simulation(simFreq,bound1,bound2);
        simHandler = scheduler.scheduleAtFixedRate(sim,(long) 0, (long) Math.round(1000/simFreq), TimeUnit.MILLISECONDS);
    }

    public void endSim() {
        simHandler.cancel(true);
    }

    public void startDraw() {
        activeSim.draw();
    }

    public void addActor(PhysicsBody body) {
        activeSim.addActor(body);
    }

    public void addActors(ArrayList<PhysicsBody> bodies) {
        for (PhysicsBody body : bodies) {
            activeSim.addActor(body);
        }
    }

    public PhysicsBody objectAtPoint(PVector v) {
        return activeSim.objectAtPoint(v);
    }

    private class Simulation {
        ArrayList<PhysicsBody> actors = new ArrayList<PhysicsBody>();
        float freqency; //what the frequency of the simulation is, important for physics calculations. 
        PVector gravity = new PVector(0,9.8); //Gravity in the scene, defaulted to earth's in M/s
        PVector normGravity; //gravity normalized to the frequency. precomputed to save time.
        float scale = 500; //How many pixels equates to a meter. Used for calculating speeds.
        float airDensity = 1.225; //density of the air, defaulted to earth at sea level
        private final ExecutorService workPool = Executors.newCachedThreadPool();
        PVector bound1;
        PVector bound2;

        public Simulation(float simFreq, PVector _bound1, PVector _bound2) {
            freqency = simFreq;
            bound1 = _bound1;
            bound2 = _bound2;
            normGravity = new PVector(gravity.x/simFreq,gravity.y/simFreq);
        }

        public Simulation(float simFreq, PVector _bound1, PVector _bound2, PVector _gravity) {
            freqency = simFreq;
            bound1 = _bound1;
            bound2 = _bound2;
            gravity = _gravity;
            normGravity = new PVector(_gravity.x/simFreq,_gravity.y/simFreq);
        }

        public Simulation(float simFreq, PVector _bound1, PVector _bound2, PVector _gravity, float _scale) {
            freqency = simFreq;
            bound1 = _bound1;
            bound2 = _bound2;
            gravity = _gravity;
            scale = _scale;
            normGravity = new PVector(_gravity.x/simFreq,_gravity.y/simFreq);
        }

        void addActor(PhysicsBody b) {
            actors.add(b);
        }

        public PhysicsBody objectAtPoint(PVector v) {
            for(PhysicsBody actor : actors) {
                if (v.x >= actor.nextAxisBox.minx && actor.nextAxisBox.maxx >= v.x && v.y >= actor.nextAxisBox.miny && actor.nextAxisBox.maxy >= v.y) {
                    return actor;
                }
            }
            return null;
        }


        void step() {
            if (selected != null) {
                selected.setVector(new PhysVector());
                selected.setGravityMode(false);
                selected.position.x = mouseX;
                selected.position.y = mouseY;
            }
            for (PhysicsBody actor : actors) {
                if (actor.gravityAffected() == true) {
                    actor.impulse(normGravity);
                }
                actor.startstep(freqency, scale);
                actor.checkCollision(actors,bound1,bound2,freqency,scale);
                actor.endstep();
            }
        }

        void draw() {
            for (PhysicsBody actor : actors) {
                actor.draw();
            }
        }
    }
}