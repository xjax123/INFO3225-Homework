class UiManager {
    public UiManager() {}
    HashMap<String, UIGroup> uiMap = new HashMap<String, UIGroup>();
    ArrayList<UIGroup> activeUI = new ArrayList<UIGroup>();
    ArrayList<UIGroup> cleanup = new ArrayList<UIGroup>();
    boolean awaitingInput = false;

    public void drawUI(PGraphics buffer) {
        int min = getMinLayer()-10;
        int max = getMaxLayer()+20;
        for (int x = min; x <= max; x++) {
            for(UIGroup body : activeUI) {
                body.draw(buffer,x);
            }
        }
    }

    public void keyInput(int key) {
        if (awaitingInput) {
            for (UIGroup body : activeUI) {
                body.input(key);
            }
        }
    }

    public void registerGroup(String s, UIGroup g) {
        uiMap.put(s,g);
    }

    public void loadGroup(String s) {
        UIGroup g = uiMap.get(s);
        activeUI.add(g);
        g.onLoad();
    }

    public void removeGroup(String s) throws Exception{
        UIGroup g = uiMap.get(s);
        int id = g.getID();
        UIGroup rg = findGroupByID(id);
        cleanup.add(rg);
    }

    public void cleanup() {
        for (UIGroup r : cleanup) {
            println("UI Element "+r.id + " Cleaned Up");
            activeUI.remove(r);
        }
        cleanup = new ArrayList<UIGroup>();
    }

    public int getMinLayer() {
        int min = 99999;
        for (UIGroup g : activeUI) {
            int m = g.getMaxLayer();
            if (m < min) {
                min = m;
            }
        }
        if (min == 99999) {
            min = 0;
        }
        return min;
    }

    public void waitingForInput(boolean status) {
        awaitingInput = status;
    }

    public int getMaxLayer() {
        int max = -99999;
        for (UIGroup g : activeUI) {
            int m = g.getMaxLayer();
            if (m > max) {
                max = m;
            }
        }
        if (max == -99999) {
            max = 0;
        }
        return max;
    }
    public UIBody findByID(int id) throws Exception{
        for(UIGroup body : activeUI) {
            if (body.getID(id) == id) {
                return body.getElementByID(id);
            }
        }
        throw new Exception("UI Element of ID " + id +" Not Found In UI");
    }

    public UIGroup findGroupByID(int id) throws Exception{
        for(UIGroup body : activeUI) {
            if (body.getID() == id) {
                return body;
            }
        }
        throw new Exception("UI Element of ID " + id +" Not Found In UI");
    }
    public int getUIArraySize() {
        return activeUI.size();
    }
}

abstract class UIBody {
    protected int id = 0;
    protected int renderLayer = 0;
    protected PVector position = new PVector(0,0);
    protected boolean active = true;
    protected boolean visible = true;

    public UIBody(UIBody body) {
        id = body.getID();
        position.x = body.getPosition().x;
        position.y = body.getPosition().y;
    }    
    public UIBody(PVector _position) {
        position.x = _position.x;
        position.y = _position.y;
    }   
    public UIBody(int _id, PVector _position) {
        id = _id;
        position.x = _position.x;
        position.y = _position.y;
    } 
    public UIBody(int _id, int _layer, PVector _position) {
        id = _id;
        renderLayer = _layer;
        position.x = _position.x;
        position.y = _position.y;
    }
    
    public void onClick() {}

    public boolean checkClicked() {return false;}

    public void onLoad() {}

    public int getID() {
        return id;
    } 
    public int getLayer() {
        return renderLayer;
    }       
    public int getID(int _id) {
        return id;
    }

    public void setPosition(PVector vec) {
        position.x = vec.x;
        position.y = vec.y;
    }
    public void setPosition(float x, float y) {
        position.x = x;
        position.y = y;
    }

    public PVector getPosition() {
        return position;
    }

    public abstract void draw(PGraphics buffer, int layer);
}

class UIText extends UIBody{
    String uiText = "";
    int textSize = 16;
    Color textColor = new Color(255,255,255);
    int strokeSize = 0;
    Color strokeColor = new Color(0,0,0);
    public UIText(UIText body) {
        super(body);
        uiText = body.getText();
        textSize = body.getSize();
        textColor = body.getColor();
    }    
    public UIText(PVector _position, String text, int size, Color col) {
        super(_position);
        uiText = text;
        textSize = size;
        textColor = col;
    }   
    public UIText(int _id, PVector _position, String text, int size, Color col) {
        super(_id,_position);
        uiText = text;
        textSize = size;
        textColor = col;
    }
    public UIText(int _id, int _layer, PVector _position, String text, int size, Color col) {
        super(_id, _layer, _position);
        uiText = text;
        textSize = size;
        textColor = col;
    }
    public UIText(int _id, int _layer, PVector _position, String text, int size, Color col, int strokeWeight, Color _strokeColor) {
        super(_id, _layer, _position);
        uiText = text;
        textSize = size;
        textColor = col;
        strokeSize = strokeWeight;
        strokeColor = _strokeColor;
    }

    public String getText() {
        return uiText;
    }
    public int getSize() {
        return textSize;
    }

    public void setText(String text) {
        uiText = text;
    }    
    public void setSize(int size) {
        textSize = size;
    }

    public Color getColor() {
        return textColor;
    }

    public void draw(PGraphics buffer, int layer) {
        if (!visible || layer != renderLayer) {
            return;
        }
        buffer.strokeWeight(strokeSize);
        buffer.stroke(strokeColor.red, strokeColor.green, strokeColor.blue);
        buffer.textSize(textSize);
        buffer.fill(textColor.red, textColor.green, textColor.blue);
        buffer.text(uiText,position.x,position.y);
        buffer.stroke(0);
    }
}

class UIShape extends UIBody {
    PShape shape;
    public UIShape(UIShape body) {
        super(body);
        shape = body.getShape();
    }
    public UIShape(PVector _position, PShape _shape) {
        super(_position);
        shape = _shape;
    }   
    public UIShape(int _id, PVector _position, PShape _shape) {
        super(_id,_position);
        shape = _shape;
    } 
    public UIShape(int _id, int _layer, PVector _position, PShape _shape) {
        super(_id,_layer,_position);
        shape = _shape;
    }

    public PShape getShape() {
        return shape;
    }

    public void draw(PGraphics buffer, int layer) {
        if (!visible || layer != renderLayer) {
            return;
        }
        buffer.shape(shape,position.x,position.y);
    }
}

class UIGroup extends UIBody {
    ArrayList<UIBody> bodies = new ArrayList<UIBody>();
    public UIGroup(UIGroup body) {
        super(body);
        bodies = body.getBodies();
    }    
    public UIGroup(UIBody[] _bodies) {
        super(new PVector(0,0));
        for (UIBody b : _bodies) {
            bodies.add(b);
        }
    }   
    public UIGroup(int _id, UIBody[] _bodies) {
        super(_id,new PVector(0,0));
        for (UIBody b : _bodies) {
            bodies.add(b);
        }
    } 
    public UIGroup(int _id, int _layer, UIBody[] _bodies) {
        super(_id,_layer,new PVector(0,0));
        for (UIBody b : _bodies) {
            bodies.add(b);
        }
    }

    public ArrayList<UIBody> getBodies() {
        return bodies;
    }

    public void onLoad() {
        for (UIBody b :bodies) {
            b.onLoad();
        }
    }

    @Override
    public int getID(int _id) {
        for(UIBody body : bodies) {
            if (body.getID() == _id) {
                return body.getID();
            }
        }
        return -1;
    }
    public UIBody getElementByID(int id) throws Exception {
        for(UIBody body : bodies) {
            if (body.getID() == id) {
                return body;
            }
        }
        throw new Exception("UI Element of ID " + id +" Not Found In Group");
    }

    public int getMinLayer() {
        int min = 99999;
        for (UIBody b : bodies) {
            if (b.getLayer() < min) {
                min = b.getLayer();
            }
        }
        if (min == 99999) {
            min = 0;
        }
        return min;
    }

    public int getMaxLayer() {
        int max = -99999;
        for (UIBody b : bodies) {
            if (b.getLayer() > max) {
                max = b.getLayer();
            }
        }
        if (max == -99999) {
            max = 0;
        }
        return max;
    }

    public void input(int key) {}

    public void draw(PGraphics buffer, int layer) {
        if (!visible || layer != renderLayer) {
            return;
        }
        int min = getMinLayer();
        int max = getMaxLayer();
        for (int x = min; x <= max; x++) {
            for(UIBody body : bodies) {
                body.draw(buffer,x);
            }
        }

    }

    @Override
    public String toString() {
        String temp = "[";
        for (UIBody b : bodies) {
            temp += b.getID();
            temp += " ";
        }
        temp += "]";
        return temp;
    }
}

class OnDeathPopup extends UIGroup {
    public OnDeathPopup(UIGroup body) {
        super(body);
    }    
    public OnDeathPopup(UIBody[] _bodies) {
        super(_bodies);
    }   
    public OnDeathPopup(int _id, UIBody[] _bodies) {
        super(_id,_bodies);
    } 
    public OnDeathPopup(int _id, int _layer, UIBody[] _bodies) {
        super(_id,_layer,_bodies);
    }

    @Override
    public void onLoad() {
        super.onLoad();
        uiManager.waitingForInput(true);
    }

    @Override
    public void input(int key) {
        if (key == 10) {
            sceneManager.reload();
            try {
                uiManager.removeGroup("death");
            } catch (Exception e) {
                println(e.toString());
            }
        }
    }
}

class DevGroup extends UIGroup {
    public DevGroup(UIGroup body) {
        super(body);
    }    
    public DevGroup(UIBody[] _bodies) {
        super(_bodies);
    }   
    public DevGroup(int _id, UIBody[] _bodies) {
        super(_id,_bodies);
    } 
    public DevGroup(int _id, int _layer, UIBody[] _bodies) {
        super(_id,_layer,_bodies);
    }

    @Override
    public void onLoad() {
        try {
            posText = (UIText) this.getElementByID(90000);
            stateText = (UIText) this.getElementByID(100000);
        } catch (Exception e) {
            println(e.toString());
        }
    }
}

class UIButton extends UIBody {
    protected UIFunction clickFunc;
    protected PShape shape;
    protected String text; 
    public UIShape(UIShape body) {
        super(body);
        shape = body.getShape();
    }
    public UIShape(PVector _position, PShape _shape, String _buttonText, UIFunction _onClick) {
        super(_position);
        shape = _shape;
        text = _buttonText;
        clickFunc = _onClick;
    }   
    public UIShape(int _id, PVector _position, PShape _shape, String _buttonText, UIFunction _onClick) {
        super(_id,_position);
        shape = _shape;
        text = _buttonText;
        clickFunc = _onClick;
    } 
    public UIShape(int _id, int _layer, PVector _position, PShape _shape, String _buttonText, UIFunction _onClick) {
        super(_id,_layer,_position);
        shape = _shape;
        text = _buttonText;
        clickFunc = _onClick;
    }
    public void draw(PGraphics buffer, int layer) {}
}

class AABB {
    public x1;
    public x2;
    public y1;
    public y2;
}

class Color {
    public int red;
    public int green;
    public int blue;

    public Color(int _red, int _green, int _blue) {
        red = _red;
        green = _green;
        blue = _blue;
    }
    
    public color getPColor() {
        return color(red, green, blue);
    }
}