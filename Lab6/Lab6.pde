//variables
float camX, camY, camZ;
float camRotY = 0;
float camRotX = 45;
float originx = 0;
float originy = 0;
float originz = 0;
PGraphics main, hud;
ArrayList<RenderObject> renderList = new ArrayList<RenderObject>();
ArrayList<Light> sceneLights = new ArrayList<Light>();

//settup modifiers
float sceneSize = 10000;
float squaresSpacing = 50;

//Settings Variables
boolean renderBackground = true;
boolean renderOverlay = false;
boolean lightsOn = true;
boolean passiveLight = true;

void setup() {
    size(1920,1061, P3D);
    frameRate(60);
    hud = createGraphics(1920,1061,P3D);
    hud.smooth(8);
    hud.ortho();
    main = createGraphics(1920,1061,P3D);
    main.smooth(8);
    setupShapes();
    setupLights();
}

void draw() {
    //Background Rendering
    renderBackground();

    //Main Buffer rendering
    renderMain();

    //HUD buffer Rendering
    renderHud();

    //render final outputs to screen
    image(main,0,0);
    image(hud,0,0);
}

void setupShapes() {
    noStroke();
    //Background Set
    PShape setMain = createShape(GROUP);
    //Floor
    fill(#55342B);
    ambient(#55342B);
    PShape floor = createShape(BOX,500,8,300);
    floor.translate(0,0,50);

    //Grass
    fill(#317103);
    ambient(#317103);
    PShape grass = createShape(BOX,500,8,500);
    grass.translate(0,0,-350);
    generateGrass(2000,setMain,500,500,new PVector(0,0,-350));

    //Trees
    genTree(setMain,200,20,200,150,100,150, new PVector(-200,0,-500));
    
    //Hedge
    //Suprised the function was versatile enough for this, this needed no tweaking to work.
    genTree(setMain,0,0,600,50,150,450, new PVector(200,0,-350));

    //carpet
    fill(#513e40);
    ambient(#513e40);
    PShape carpet = createShape(GROUP);
    PShape outerRing = genCylinder(30,100,100,2);
    fill(#4b5e6c);
    ambient(#4b5e6c);
    PShape middleRing = genCylinder(30,80,80,2);
    middleRing.translate(0,0,0.1);
    fill(#403f5f);
    ambient(#403f5f);
    PShape centerRing = genCylinder(30,40,40,2);
    centerRing.translate(0,0,0.2);
    

    carpet.addChild(outerRing);
    carpet.addChild(middleRing);
    carpet.addChild(centerRing);
    carpet.scale(1.2);
    carpet.rotateX(radians(90));
    carpet.translate(0,-5,20);
    //Wall
    fill(#a67c52);
    ambient(#a67c52);
    PShape wallMain = createShape(GROUP);
    PShape wallSeg1 = createShape(BOX,500,50,8);
    wallSeg1.translate(0,-25,-96);
    PShape wallSeg2 = createShape(BOX,500,50,8);
    wallSeg2.translate(0,-175,-96);
    PShape wallSeg3 = createShape(BOX,100,100,8);
    wallSeg3.translate(-200,-100,-96);
    PShape wallSeg4 = createShape(BOX,150,100,8);
    wallSeg4.translate(175,-100,-96);
    wallMain.addChild(wallSeg1);
    wallMain.addChild(wallSeg2);
    wallMain.addChild(wallSeg3);
    wallMain.addChild(wallSeg4);

    //Window Frame
    //Its a french window, aka a pain in my ass.
    fill(#F6F8E8);
    ambient(#F6F8E8);
    PShape winBottom = genHex(new PVector(-125,0,0),new PVector(-60,0,-50),new PVector(60,0,-50),new PVector(125,0,0),new PVector(-125,-6,0),new PVector(-60,-6,-50),new PVector(60,-6,-50),new PVector(125,-6,0));
    PShape winBottomBox = createShape(BOX,250,6,8);
    winBottomBox.translate(0,-3,4);
    winBottom.addChild(winBottomBox);
    winBottom.translate(-25,-50,-100);
    PShape winTop = genHex(new PVector(-125,0,0),new PVector(-60,0,-50),new PVector(60,0,-50),new PVector(125,0,0),new PVector(-125,-6,0),new PVector(-60,-6,-50),new PVector(60,-6,-50),new PVector(125,-6,0));
    PShape winTopBox = createShape(BOX,250,6,8);
    winTopBox.translate(0,-3,4);
    winTop.addChild(winTopBox);
    winTop.translate(-25,-144,-100);
    //pillars    
    PShape winPillar1 = createShape(BOX,6,100,6);
    winPillar1.translate(35,-100,-144);
    PShape winPillar2 = createShape(BOX,6,100,6);
    winPillar2.translate(-85,-100,-144);
    PShape winPillar3 = createShape(BOX,6,88,6);
    winPillar3.translate(-147,-100,-95);
    PShape winPillar4 = createShape(BOX,6,88,6);
    winPillar4.translate(97,-100,-95);
    PShape winPillarCross1 = createShape(BOX,6,120,6);
    winPillarCross1.rotateZ(radians(90));
    winPillarCross1.translate(-25,-100,-144);
    PShape winPillarCross2 = createShape(BOX,6,80,6);
    winPillarCross2.rotateZ(radians(90));
    winPillarCross2.translate(-35,0,3);
    winPillarCross2.rotateY(radians(38));
    winPillarCross2.translate(-90,-100,-144);
    PShape winPillarCross3 = createShape(BOX,6,80,6);
    winPillarCross3.rotateZ(radians(90));
    winPillarCross3.translate(35,0,3);
    winPillarCross3.rotateY(radians(-38));
    winPillarCross3.translate(40,-100,-144);


    fill(150,150,150,30);
    ambient(255,255,255);
    specular(255,255,255);
    shininess(255);
    PShape winPane1 = createShape(BOX,100,120,2);
    winPane1.rotateZ(radians(90));
    winPane1.translate(-25,-100,-144);
    PShape winPane2 = createShape(BOX,100,80,2);
    winPane2.rotateZ(radians(90));
    winPane2.translate(-35,0,3);
    winPane2.rotateY(radians(38));
    winPane2.translate(-90,-100,-144);
    PShape winPane3 = createShape(BOX,100,80,2);
    winPane3.rotateZ(radians(90));
    winPane3.translate(35,0,3);
    winPane3.rotateY(radians(-38));
    winPane3.translate(40,-100,-144);
    specular(0,0,0);
    shininess(0);


    setMain.addChild(floor);
    setMain.addChild(grass);
    setMain.addChild(carpet);
    setMain.addChild(wallMain);
    setMain.addChild(winBottom);
    setMain.addChild(winTop);
    setMain.addChild(winPillar1);
    setMain.addChild(winPillar2);
    setMain.addChild(winPillar3);
    setMain.addChild(winPillar4);
    setMain.addChild(winPillarCross1);
    setMain.addChild(winPillarCross2);
    setMain.addChild(winPillarCross3);
    setMain.addChild(winPane1);
    setMain.addChild(winPane2);
    setMain.addChild(winPane3);


    //Main Chair Body
    fill(#A8415B);
    ambient(#A8415B);
    PShape chair = createShape(GROUP);
    PShape arm1 = createShape(BOX,15,40,80);
    PShape arm2 = createShape(BOX,15,40,80);
    arm2.translate(80,0,0);
    PShape bottom = createShape(BOX,70,8,75);
    bottom.translate(40,15,-2);
    PShape cushon = createShape(BOX,65,15,65);
    cushon.translate(40,5,-2);
    PShape back = createShape(BOX,70,75,8);
    back.translate(40,-25,-35);

    //Blue Cushion
    fill(#506d73);
    ambient(#506d73);
    PShape bCushion = createShape(BOX,50,5,40);
    bCushion.translate(40,-6,-24);
    bCushion.rotateX(radians(-30));

    //Green Backing
    fill(#5a4c32);
    ambient(#5a4c32);
    PShape backCloth = createShape(BOX,50,30,10);
    backCloth.translate(40,-50,-35);

    fill(#deb887);
    ambient(#deb887);
    //Creating Chair Legs
    PShape leg1 = genCylinder(4,10,20,10);
    leg1.scale(0.4);
    leg1.rotateX(radians(90));
    leg1.rotateY(radians(45));
    leg1.translate(0,22,33);
    PShape leg2 = genCylinder(4,10,20,10);
    leg2.scale(0.4);
    leg2.rotateX(radians(90));
    leg2.rotateY(radians(45));
    leg2.translate(80,22,33);
    PShape leg3 = genCylinder(4,10,20,10);
    leg3.scale(0.4);
    leg3.rotateX(radians(90));
    leg3.rotateY(radians(45));
    leg3.translate(0,22,-33);
    PShape leg4 = genCylinder(4,10,20,10);
    leg4.scale(0.4);
    leg4.rotateX(radians(90));
    leg4.rotateY(radians(45));
    leg4.translate(80,22,-33);

    //finalizing the shape
    chair.addChild(arm1);
    chair.addChild(arm2);
    chair.addChild(bottom);
    chair.addChild(cushon);
    chair.addChild(back);
    chair.addChild(bCushion);
    chair.addChild(backCloth);
    chair.addChild(leg1);
    chair.addChild(leg2);
    chair.addChild(leg3);
    chair.addChild(leg4);
    renderList.add(new RenderObject(new PVector(-100,-28,0),0,10,0,chair));

    //Stool
    PShape stool1 = createShape(GROUP);
    //Cushion
    fill(#deb887);
    ambient(#deb887);
    PShape stoolCushion = genCylinder(20,20,20,10);
    stoolCushion.rotateX(radians(90));
    //Wood
    fill(#55342B);
    ambient(#55342B);
    PShape stoolBottom = genCylinder(20,19,19,5);
    stoolBottom.rotateX(radians(90));
    stoolBottom.translate(0,7,0);
    PShape sLeg1 = genCylinder(20,3,5,15);
    sLeg1.rotateX(radians(90));
    sLeg1.translate(8,15,8);
    PShape sLeg2 = genCylinder(20,3,5,15);
    sLeg2.rotateX(radians(90));
    sLeg2.translate(-8,15,8);
    PShape sLeg3 = genCylinder(20,3,5,15);
    sLeg3.rotateX(radians(90));
    sLeg3.translate(8,15,-8);
    PShape sLeg4 = genCylinder(20,3,5,15);
    sLeg4.rotateX(radians(90));
    sLeg4.translate(-8,15,-8);

    stool1.addChild(stoolCushion);
    stool1.addChild(stoolBottom);
    stool1.addChild(sLeg1);
    stool1.addChild(sLeg2);
    stool1.addChild(sLeg3);
    stool1.addChild(sLeg4);
    renderList.add(new RenderObject(new PVector(30,-28,65),0,00,0,stool1));

    //second chair
    //borrows alot from the stool due to similar design
    fill(#deb887);
    ambient(#deb887);
    PShape chair2 = createShape(GROUP);
    //Arms
    PShape chair2ArmOne = createShape(BOX,5,25,35);
    chair2ArmOne.rotateZ(radians(-8));
    chair2ArmOne.translate(-19,-7,0);
    PShape chair2ArmTwo = createShape(BOX,5,25,35);
    chair2ArmTwo.rotateZ(radians(8));
    chair2ArmTwo.translate(19,-7,0);
    //Back
    PShape chair2Back = createShape(BOX,8,25,40);
    chair2Back.rotateY(radians(90));
    chair2Back.translate(0,-10,-15);
    PShape chair2BackWide = genHex(new PVector(-20,0,-4),new PVector(-20,0,4),new PVector(20,0,4),new PVector(20,0,-4),new PVector(-30,-40,-4),new PVector(-30,-40,4),new PVector(30,-40,4),new PVector(30,-40,-4));
    chair2BackWide.translate(0,-22.5,-15);
    PShape chair2Top = genHex(new PVector(-20,0,-4),new PVector(-20,0,4),new PVector(20,0,4),new PVector(20,0,-4),new PVector(-10,-10,-4),new PVector(-10,-10,4),new PVector(10,-10,4),new PVector(10,-10,-4));
    chair2Top.translate(0,-62.5,-15);
    //Seat
    PShape chair2Cushion = genCylinder(20,20,20,10);
    chair2Cushion.rotateX(radians(90));
    //Pillow
    fill(#925e46);
    ambient(#925e46);
    //Wood
    fill(#55342B);
    ambient(#55342B);
    PShape chair2Bottom = genCylinder(20,19,19,5);
    chair2Bottom.rotateX(radians(90));
    chair2Bottom.translate(0,7,0);
    PShape cLeg1 = genCylinder(20,3,5,15);
    cLeg1.rotateX(radians(90));
    cLeg1.translate(8,15,8);
    PShape cLeg2 = genCylinder(20,3,5,15);
    cLeg2.rotateX(radians(90));
    cLeg2.translate(-8,15,8);
    PShape cLeg3 = genCylinder(20,3,5,15);
    cLeg3.rotateX(radians(90));
    cLeg3.translate(8,15,-8);
    PShape cLeg4 = genCylinder(20,3,5,15);
    cLeg4.rotateX(radians(90));
    cLeg4.translate(-8,15,-8);

    chair2.scale(1.3);
    chair2.addChild(chair2Cushion);
    chair2.addChild(chair2Bottom);
    chair2.addChild(cLeg1);
    chair2.addChild(cLeg2);
    chair2.addChild(cLeg3);
    chair2.addChild(cLeg4);
    chair2.addChild(chair2ArmOne);
    chair2.addChild(chair2ArmTwo);
    chair2.addChild(chair2Back);
    chair2.addChild(chair2BackWide);
    chair2.addChild(chair2Top);
    renderList.add(new RenderObject(new PVector(50,-35,5),0,-10,0,chair2));

    //render the main scene last so the windows work.
    renderList.add(new RenderObject(new PVector(0,2,0),0,0,0,setMain));
}

void setupLights() {
    //Garden Light
    sceneLights.add(new SpotLight(new PVector(0,-300,-400), 250,213,165, new PVector(0,1,0), PI/2, 0.2f));
    //Window Light
    //sceneLights.add(new SpotLight(new PVector(0,-100,-400), 250,213,165, new PVector(0,0.2,-1), PI/2, 0f));
    //Offscreen Light
    sceneLights.add(new SpotLight(new PVector(350,-50,200), 250,213,165, new PVector(-1,0.1,1), PI/32, 0f));
    //Lamp 1
    sceneLights.add(new Light(new PVector(-150,-75,-25),100,100,100));
    //Lamp 2
    sceneLights.add(new Light(new PVector(120,-90,-20),175,175,175));
}

void renderBackground() {
    main.beginDraw();

    //Main Buffer Camera Settup
    main.beginCamera();
    main.camera();
    main.translate(1920/2,1080/2,0);
    main.translate(camX,camY,camZ);
    main.rotateX(radians(-90));
    main.rotateX(radians(camRotX));
    main.rotateY(radians(camRotY));
    main.endCamera();

    //background Settup
    main.background(#a0cdee);

    if (renderBackground == false) {
        return;
    }
    
    //Main 3 Axis Linework
    main.fill(255);
    main.sphere(5);
    main.translate(originx, originy, originz);
    main.strokeWeight(2);
    main.stroke(color(150,0,0));
    main.line(0, 0, 0, sceneSize, 0, 0);
    main.line(0, 0, 0, -sceneSize, 0, 0);
    main.stroke(color(0,150,0));
    main.line(0, 0, 0, 0, sceneSize, 0);
    main.line(0, 0, 0, 0, -sceneSize, 0);
    main.stroke(color(0,0,150));
    main.line(0, 0, 0, 0, 0, sceneSize);
    main.line(0, 0, 0, 0, 0, -sceneSize);

    //Grid linework
    main.stroke(125);
    main.strokeWeight(1);
    int sqrs = Math.round(sceneSize/squaresSpacing);
    for (int x = -sqrs; x < sqrs;x++) {
        if (x==0) {continue;}
        float xSpace = x*squaresSpacing;
        main.line(xSpace, 0, 0, xSpace,0, sceneSize);
        main.line(xSpace, 0, 0, xSpace,0, -sceneSize);
    }
    for (int z = -sqrs; z < sqrs; z++) {
        if (z==0) {continue;}
        float zSpace = z*squaresSpacing;
        main.line(0, 0, zSpace, sceneSize, 0, zSpace);
        main.line(0, 0, zSpace, -sceneSize, 0, zSpace);
    }
    
    main.endDraw();
}

void renderMain() {
    main.beginDraw();
    main.translate(originx, originy, originz);

    //Scene Settup
    if (passiveLight) {
        main.ambientLight(75, 75, 75);
        main.directionalLight(255, 255, 255, 0, 1, 1);
        for (Light l : sceneLights) {
            l.render(main);
        }
    } else {
        main.ambientLight(50, 50, 50);
        for (Light l : sceneLights) {
            l.light(main);
        }
    }
    if (!lightsOn) {
        main.noLights();
    }

    //Objects Rendering
    for (RenderObject ren : renderList) {
        main.pushMatrix();
        PVector v = ren.pos;
        main.translate(ren.pos.x,ren.pos.y,ren.pos.z);
        main.rotateX(radians(ren.rotX));
        main.rotateY(radians(ren.rotY));
        main.rotateZ(radians(ren.rotZ));
        main.shape(ren.shape,0,0);
        main.popMatrix();
    }

    
    main.endDraw();
}

void renderHud() {
    hud.beginDraw();
    //HUD Spidle Camera, matches main camera rotation.
    hud.beginCamera();
    hud.camera();
    hud.translate(0,0,-35);
    hud.rotateX(radians(camRotX-90));
    hud.rotateY(radians(camRotY));
    hud.endCamera();

    //HUD Settup
    background(0,0,0,0);

    if (renderOverlay == false) {
        hud.endDraw();
        return;
    }
    //Spindle Rendering
    hud.pushMatrix();
    hud.translate(0,0,0);
    hud.strokeWeight(5);
    hud.stroke(color(255,0,0));
    hud.line(0, 0, 0, 30, 0, 0);
    hud.stroke(color(0,255,0));
    hud.line(0, 0, 0, 0, 30, 0);
    hud.stroke(color(0,0,255));
    hud.line(0, 0, 0, 0, 0, 30);
    hud.noStroke();
    hud.sphere(5);
    hud.popMatrix();
    hud.endDraw();
}

void mouseDragged(MouseEvent event) {
    float newX = mouseX - pmouseX;
    float newY = mouseY - pmouseY;
    if (mouseButton == LEFT) {
        camX += newX;
        camY += newY;
    }
    if (mouseButton == RIGHT) {
        camRotY += newX*0.5;
        camRotX -= newY*0.5;
        float testrot = camRotX-newX*0.5;
        if (testrot > 170) {
            camRotX = 170;
        } else if (testrot < 10) {
            camRotX = 10;
        }
        if (camRotX > 360) {
            camRotX -= 360;
        } else if (camRotX < 0) {
            camRotX += 360;
        }
        if (camRotY > 360) {
            camRotY -= 360;
        } else if (camRotY < 0) {
            camRotY += 360;
        }
    }
}

void mouseWheel(MouseEvent event) {
    if (event.getCount() > 0) {
        if (camZ >= -400) {
            camZ -= 20;
        }
    } else if (event.getCount() < 0) {
        if (camZ <= 800) {
            camZ += 20;
        }
    }
}
void keyPressed() {
    if (key == 'b') {
            if (renderBackground == true) {
                renderBackground = false;
            } else {
                renderBackground = true;
            }
    } 
    if (key == 'o') {
            if (renderOverlay == true) {
                renderOverlay = false;
            } else {
                renderOverlay = true;
            }
    }
    if (key == 'l') {
            if (lightsOn == true) {
                lightsOn = false;
            } else {
                lightsOn = true;
            }
    }
    if (key == 'p') {
            if (passiveLight == true) {
                passiveLight = false;
            } else {
                passiveLight = true;
            }
    }
    if (key == 'r') {
        camX = 0;
        camY = 0;
        camZ = 0;
        camRotX = 45;
        camRotY = 0;
    }

    float adjrot = camRotY-45;
    if (adjrot > 360) {
        adjrot -= 360;
    } else if (camRotY < 0) {
        adjrot += 360;
    }
    if (key == 'w') {
        if (adjrot >= 0 && adjrot <= 90) {
            originx -= squaresSpacing;
        } else if (adjrot >= 90 && adjrot <= 180) {
            originz -= squaresSpacing;
        } else if (adjrot >= 180 && adjrot <= 270) {
            originx += squaresSpacing;
        } else {
            originz += squaresSpacing;
        }
    }
    if (key == 's') {
        if (adjrot >= 0 && adjrot <= 90) {
            originx += squaresSpacing;
        } else if (adjrot >= 90 && adjrot <= 180) {
            originz += squaresSpacing;
        } else if (adjrot >= 180 && adjrot <= 270) {
            originx -= squaresSpacing;
        } else {
            originz -= squaresSpacing;
        }
    }
    if (key == 'a') {
        if (adjrot >= 0 && adjrot <= 90) {
            originz += squaresSpacing;
        } else if (adjrot >= 90 && adjrot <= 180) {
            originx -= squaresSpacing;
        } else if (adjrot >= 180 && adjrot <= 270) {
            originz -= squaresSpacing;
        } else {
            originx += squaresSpacing;
        }
    }
    if (key == 'd') {
        if (adjrot >= 0 && adjrot <= 90) {
            originz -= squaresSpacing;
        } else if (adjrot >= 90 && adjrot <= 180) {
            originx += squaresSpacing;
        } else if (adjrot >= 180 && adjrot <= 270) {
            originz += squaresSpacing;
        } else {
            originx -= squaresSpacing;
        }
    }
    if (key == 'q') {
        originy -= squaresSpacing;
    }
    if (key == 'e') {
        originy += squaresSpacing;
    }
}

PShape genCylinder(int sides, float r1, float r2, float h)
{
    PShape cyl = createShape(GROUP);
    float angle = 360 / sides;
    float halfHeight = h / 2;
    // top
    PShape top = createShape();
    top.beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r1;
        float y = sin( radians( i * angle ) ) * r1;
        top.vertex( x, y, -halfHeight);
    }
    top.endShape(CLOSE);
    // bottom
    PShape bottom = createShape();
    bottom.beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r2;
        float y = sin( radians( i * angle ) ) * r2;
        bottom.vertex( x, y, halfHeight);
    }
    bottom.endShape(CLOSE);
    // draw body
    PShape body = createShape();
    body.beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < sides + 1; i++) {
        float x1 = cos( radians( i * angle ) ) * r1;
        float y1 = sin( radians( i * angle ) ) * r1;
        float x2 = cos( radians( i * angle ) ) * r2;
        float y2 = sin( radians( i * angle ) ) * r2;
        body.vertex( x1, y1, -halfHeight);
        body.vertex( x2, y2, halfHeight);
    }
    body.endShape(CLOSE);
    cyl.addChild(top);
    cyl.addChild(bottom);
    cyl.addChild(body);
    return cyl;
}

//Generate any arbitrary Hexadron from 8 given points, repersenting the corners, as defined clockwise, bottom to top.
//b1-4 are the bottom 4 points
//t1-4 are the top 4 points.
//though its not strictly required to have them as top or bottom.
PShape genHex(PVector b1, PVector b2, PVector b3, PVector b4, PVector t1, PVector t2, PVector t3, PVector t4) {
    PShape finalShape = createShape(GROUP);

    //Top
    PShape top = createShape();
    top.beginShape();
    top.vertex(t1.x,t1.y,t1.z);
    top.vertex(t2.x,t2.y,t2.z);
    top.vertex(t3.x,t3.y,t3.z);
    top.vertex(t4.x,t4.y,t4.z);
    top.endShape(CLOSE);

    //Bottom
    PShape bot = createShape();
    bot.beginShape();
    bot.vertex(b1.x,b1.y,b1.z);
    bot.vertex(b2.x,b2.y,b2.z);
    bot.vertex(b3.x,b3.y,b3.z);
    bot.vertex(b4.x,b4.y,b4.z);
    bot.endShape(CLOSE);

    //Side 1
    PShape s1 = createShape();
    s1.beginShape();
    s1.vertex(b1.x,b1.y,b1.z);
    s1.vertex(b2.x,b2.y,b2.z);
    s1.vertex(t2.x,t2.y,t2.z);
    s1.vertex(t1.x,t1.y,t1.z);
    s1.endShape(CLOSE);

    //Side 2
    PShape s2 = createShape();
    s2.beginShape();
    s2.vertex(b2.x,b2.y,b2.z);
    s2.vertex(b3.x,b3.y,b3.z);
    s2.vertex(t3.x,t3.y,t3.z);
    s2.vertex(t2.x,t2.y,t2.z);
    s2.endShape(CLOSE);

    //Side 3
    PShape s3 = createShape();
    s3.beginShape();
    s3.vertex(b3.x,b3.y,b3.z);
    s3.vertex(b4.x,b4.y,b4.z);
    s3.vertex(t4.x,t4.y,t4.z);
    s3.vertex(t3.x,t3.y,t3.z);
    s3.endShape(CLOSE);

    //Side 4
    PShape s4 = createShape();
    s4.beginShape();
    s4.vertex(b4.x,b4.y,b4.z);
    s4.vertex(b1.x,b1.y,b1.z);
    s4.vertex(t1.x,t1.y,t1.z);
    s4.vertex(t4.x,t4.y,t4.z);
    s4.endShape(CLOSE);

    finalShape.addChild(top);
    finalShape.addChild(bot);
    finalShape.addChild(s1);
    finalShape.addChild(s2);
    finalShape.addChild(s3);
    finalShape.addChild(s4);
    return finalShape;
}

void generateGrass(float ammount, PShape parent, float areaX, float areaZ, PVector offset) {
    PShape grassMain = createShape(GROUP);
    for (int x = 0; x < ammount; x++) {
        float posX = Math.round(Math.random()*areaX);
        float posZ = Math.round(Math.random()*areaZ);
        float height = Math.round(Math.random()*24+6);
        float width = Math.round(Math.random()*4+1);
        float rotY = Math.round(Math.random()*360);
        float rotX = Math.round(Math.random()*30-15);
        float rotZ = Math.round(Math.random()*30-15);
        PShape grassBlade = createShape(GROUP);
        PShape grassStalk = createShape(BOX,width,height,1);
        PShape grassTop = genHex(new PVector(width*0.5,0,-0.5),new PVector(width*0.5,0,0.5),new PVector(-width*0.5,0,0.5),new PVector(-width*0.5,0,-0.5),new PVector(width*0.2,-3,1),new PVector(width*0.2,-3,1.5),new PVector(-width*0.2,-3,1.5),new PVector(-width*0.2,-3,1));
        grassTop.translate(0,-height*0.5,0);
        grassBlade.addChild(grassStalk);
        grassBlade.addChild(grassTop);

        grassBlade.rotateY(radians(rotY));
        grassBlade.rotateX(radians(rotX));
        grassBlade.rotateZ(radians(rotZ));
        grassBlade.translate(posX,-6,posZ);
        grassBlade.translate(-areaX*0.5,0,-areaZ*0.5);
        grassBlade.translate(offset.x,offset.y,offset.z);
        grassMain.addChild(grassBlade);
    }
    parent.addChild(grassMain);
}

void genTree(PShape parent, float trunkHeight, float trunkWidth, float leavesAmmount, float leafAreaX, float leafAreaY, float leafAreaZ, PVector position) {
    PShape treeMain = createShape(GROUP);
    fill(#55342B);
    PShape trunk = genCylinder(20,trunkWidth,trunkWidth,trunkHeight);
    trunk.rotateX(radians(90));
    trunk.translate(0,-trunkHeight*0.5,0);
    treeMain.addChild(trunk);

    int[] colors = {#608f07,#6f9f05,#84ae09,#91b90c,#a6c70d};
    PShape leaves = createShape(GROUP);
    for (int x = 0; x < leavesAmmount; x++) {
        float posX = Math.round(Math.random()*leafAreaX);
        float posY = Math.round(Math.random()*leafAreaY);
        float posZ = Math.round(Math.random()*leafAreaZ);
        float size = Math.round(Math.random()*20+10);
        int col = (int) Math.ceil(Math.random()*5-1);
        fill(colors[col]);
        PShape leaf = createShape(SPHERE,size);
        leaf.translate(posX,posY,posZ);
        leaves.addChild(leaf);
    }
    leaves.translate(0,-trunkHeight,0);
    leaves.translate(-leafAreaX*0.5,-leafAreaY*0.8,-leafAreaZ*0.5);
    treeMain.addChild(leaves);

    treeMain.translate(position.x,position.y,position.z);
    parent.addChild(treeMain);
}

class RenderObject {
    public PVector pos;
    public float rotX;
    public float rotY;
    public float rotZ;
    public PShape shape;

    public RenderObject(PVector _pos,float _rotX,float _rotY,float _rotZ,PShape _shape) {
        pos = _pos;
        shape = _shape;
        rotX = _rotX;
        rotY = _rotY;
        rotZ = _rotZ;
    }
}

class Light {
    protected PVector pos;
    protected int red, green, blue;

    public Light(PVector _pos, int _red, int _green, int _blue) {
        pos = _pos;
        red = _red;
        green = _green;
        blue = _blue;
    }

    public void render(PGraphics buffer) {
        buffer.emissive(red, green, blue);
        buffer.pushMatrix();
        buffer.fill(0,0,0);
        buffer.translate(pos.x,pos.y,pos.z);
        buffer.noStroke();
        buffer.sphere(10);
        buffer.popMatrix();
    }

    public void light(PGraphics buffer) {
        buffer.pointLight(red, green, blue, pos.x, pos.y, pos.z);
    }
}

class SpotLight extends Light {
    protected PVector dir;
    protected float radius;
    protected float concentration;

    public SpotLight(PVector _pos, int _red, int _green, int _blue, PVector _dir, float _radius, float _concentration) {
        super(_pos, _red, _green, _blue);
        dir = _dir;
        radius = _radius;
        concentration = _concentration;
    }

    @Override
    public void render(PGraphics buffer) {
        buffer.emissive(red, green, blue);
        buffer.pushMatrix();
        buffer.fill(0,0,0);
        buffer.stroke(red,green,blue);
        buffer.strokeWeight(5);
        buffer.line(pos.x, pos.y, pos.z, pos.x+(20*dir.x), pos.y+(20*dir.y), pos.z-(20*dir.z));
        buffer.noStroke();
        buffer.translate(pos.x,pos.y,pos.z);
        buffer.sphere(10);
        buffer.popMatrix();
    }

    @Override
    public void light(PGraphics buffer) {
        main.spotLight(red, green, blue, pos.x, pos.y, pos.z, dir.x, dir.y, dir.z, radius, concentration);
    }
}