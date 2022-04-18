/*
Eksamensprojekt i teknikfaget "Computer og El-teknik" 2022
Elever:     Søren Madsen og Jakob Kristensen
Afleveret:  22/04/2022
Vejleder:   Bent Arnoldsen
Skole:      Uddannelsescenter Holstebro - HTX

OBS: Programmet er udviklet og testet på Processing 4.0 beta 7
Link: https://github.com/processing/processing4/releases/ 
*/
import processing.serial.*;

View screen = new View(0,0,1080,720);
ComDevice arduino = new ComDevice(new Serial(this, Serial.list()[0], 9600)); //Crashes with no Ardunio. Needs rework



Storage sto = new Storage();
WallFollowAlgorithm alg = new WallFollowAlgorithm();
VehicleController vc = new VehicleController(alg, sto, arduino);
Dataviewer dv = new Dataviewer(sto);



void setup() {
    surface.setResizable(true);
    surface.setTitle("Eksamen i El-teknik 2022 - Søren og Jakob");
    setupButtons();
    size(1080, 720);
    textSize(40);
    
    vc.generateNewTarget();
    sto.addDataPointToStorage(new DataPoint(-50, 50, 0, false));
    
    screen.addChildrenToList(new UIElement[] {
        new Row().addChildrenToList(new UIElement[] {
            new Column().addChildrenToList(new UIElement[] {
                TestButton0,
                TestButton1,
            }),
            
            dv,
        }),
    });
    
    
}


void draw() {
    background(100); 
    screen.display();
    screen.setComponentSize(width, height);
    screen.rescaleChildren();
    
    arduino.update();
    
}


void serialEvent(Serial $) {
    println("void serialEvent");
    arduino.serialEvent();
}


void keyPressed() {
    
}


void mousePressed() {
    if (mouseButton == LEFT) {
        for (Button button : ButtonList) {
            if (button.getButtonHover()) {
                button.setIsClicked(true);
                break;
            }
        }
        
        dv.mousePressed();
        
    }else if (mouseButton ==  CENTER) {
        dv.mouseCenter();
    }
}


void mouseReleased() {
    if (mouseButton == LEFT) {
        for (Button button : ButtonList) {
            if (button.getButtonHover() && button.getButtonStatus()) {
                button.setIsClicked(false);
                handleButton(button.getButtonID());
                break;
            }
        }
        
        dv.mouseReleased();
    }
}


void mouseDragged() {
    if (mouseButton == LEFT) {
        //print("Dragged");
        dv.mouseDragged();
    }
}


void mouseWheel(MouseEvent event) {
    dv.mouseWheel(event);
}


void handleButton(int pressedButtonID) {
    switch(pressedButtonID) {
        case 0:
            print(arduino.sendCommand(1, new int[]{100, 200}));
        break;
        
        case 1:
            print(arduino.sendCommand(2, new int[]{}));
        break;
    }
    
    
}