/*
Eksamensprojekt i teknikfaget "Computer og El-teknik" 2022
Elever:     Søren Madsen og Jakob Kristensen
Afleveret:  22/04/2022
Vejleder:   Bent Arnoldsen og Lars
Skole:      Uddannelsescenter Holstebro - HTX

OBS: Programmet er udviklet og testet på Processing 4.0 beta 7
Link: https://github.com/processing/processing4/releases/ 
*/
import processing.serial.*; //Serial communication with arduino
import java.lang.reflect.*; //Used for button actions

View screen = new View(0,0,1080,720);

ComDevice arduino = new ComDevice(new Serial(this, Serial.list()[0], 9600)); //Crashes with no Ardunio. Needs rework
Storage sto = new Storage();
WallFollowAlgorithm alg = new WallFollowAlgorithm();
VehicleController vc = new VehicleController(alg, sto, arduino);
Orchestrator orc = new Orchestrator(vc);

Dataviewer dv = new Dataviewer(sto);


void setup() {
    windowResizable(true);
    windowTitle("Eksamen i El-teknik 2022 - Søren og Jakob");
    size(1080, 720);
    textSize(40);
    
    setupInteractiveElements();
    
    //sto.addDataPointToStorage(new DataPoint( -5, 0, 0, false));
    //sto.addDataPointToStorage(new DataPoint( -20, 10, 0, true));
    //sto.addDataPointToStorage(new DataPoint( 15, 5, 75, true));
    new Row().addChildrenToList(new UIElement[] {TestButton0}).setAxisLengths(new int[]{1, 1, 2});
    
    screen.addChildrenToList(new UIElement[] {
        new Row().addChildrenToList(new UIElement[] {
            new Column().addChildrenToList(new UIElement[] {
                TestButton0,
                TestButton1,
                TestField,
            }).setAxisLengths(new int[]{2, 2, 1}),
            
            new Column().addChildrenToList(new UIElement[] {
                dv,
            }),
        }),
    });
    
    
    windowResized(); //Draw UI on start
}


void draw() {
    background(100); 
    screen.display();
    
    orc.update();
    
}


void serialEvent(Serial $) {
    println("void serialEvent");
    arduino.serialEvent();
}


void keyPressed() {
    if (key == ENTER) {
        for (TextField textField : FieldList) {
            if (textField.getFieldActive()) {
                orc.handleField(textField.getFieldID(), textField.getText());
                break;
            }
        }
    }
    
    for (TextField textField : FieldList) {
        textField.keyPressed();
    }
}


void mousePressed() {
    if (mouseButton == LEFT) {
        for (Button button : ButtonList) {
            if (button.getButtonHover()) {
                button.setIsClicked(true);
                break;
            }
        }
        
        for (TextField textField : FieldList) {
            textField.mousePressed();
        }
        
        dv.mousePressed();
        
    } else if (mouseButton ==  CENTER) {
        dv.mouseCenter();
    }
}


void mouseReleased() {
    if (mouseButton == LEFT) {
        for (Button button : ButtonList) {
            if (button.getButtonHover() && button.getButtonStatus()) {
                button.setIsClicked(false);
                orc.handleButton(button.getButtonID());
                break;
            }
        }
        
        for (TextField textField : FieldList) {
            textField.mouseReleased();
        }
        
        dv.mouseReleased();
    }
}


void mouseDragged() {
    if (mouseButton == LEFT) {
        //print("Dragged");
        dv.mouseDragged(); //<>//
    }
}


void mouseWheel(MouseEvent event) {
    dv.mouseWheel(event);
}


void windowResized() {
    //println("RESIZE");
    screen.setComponentSize(width, height);
    screen.rescaleChildren();
}
