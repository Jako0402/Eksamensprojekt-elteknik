/*
Eksamensprojekt i teknikfaget "Computer og El-teknik" 2022
Elever:     Søren Madsen og Jakob Kristensen
Afleveret:  22/04/2022
Vejleder:   Bent Arnoldsen og Lars Skjærbæk
Skole:      Uddannelsescenter Holstebro - HTX

OBS: Programmet er udviklet og testet på Processing 4.0 beta 7
Link: https://github.com/processing/processing4/releases/ 
*/
import processing.serial.*; //Serial communication with arduino
import java.lang.reflect.*; //Used for button actions

View screen = new View(0,0,1080,720); //All things drawn are children here

ComDevice arduino = new ComDevice(new Serial(this, Serial.list()[0], 9600)); //Crashes with no Ardunio. Needs rework. Communicates with vehicle
Storage sto = new Storage(); //Keeps all dataPoints and walls
WallFollowAlgorithm alg = new WallFollowAlgorithm(2); //Calculates target etc.
VehicleController vc = new VehicleController(alg, sto, arduino); //Controls communication with vehicle
Orchestrator orc = new Orchestrator(vc); //Controlds and handles responses from vehicle

Dataviewer dv = new Dataviewer(sto); //Draws UI on screen


void setup() {
    windowResizable(true);
    windowTitle("Eksamen i El-teknik 2022 - Søren og Jakob");
    size(1080, 720);
    textSize(40); //TODO: Add text scaling based on windows size
    setupInteractiveElements();

    //Setup layers
    for (int i = 0; i < layers.length; i++) {
        layers[i] = createGraphics(width, height);
        layers[i].beginDraw();
    }
    
    
    
    //UI / Mainstream
    screen.addChildrenToList(new UIElement[] {
        new Row().addChildrenToList(new UIElement[] {
            new Column().addChildrenToList(new UIElement[] {
                new Row().addChildrenToList(new UIElement[] {
                    StartButton,
                    StopButton,
                }),
                new Row().addChildrenToList(new UIElement[] {
                    SaveButton,
                    RestoreButton,
                }),
                
                
                
                TestField,
            }).setAxisLengths(new int[]{1, 1, 5}),
            
            new Column().addChildrenToList(new UIElement[] {
                dv,
            }),
        }).setAxisLengths(new int[]{1, 2}),
    });
    
    
    windowResized(); //Draw UI on start
}


void draw() {
    //Begin draw on layers
    for (int i = 0; i < layers.length; i++) {
        layers[i].beginDraw();
        layers[0].clear();
    }


    background(100); //Set background
    screen.display();
    orc.update();
    
    //End draw on lauers and show
    for (int i = 0; i < layers.length; i++) {
        layers[i].endDraw();
        image(layers[i], 0, 0, width, height); 
    }
}


void serialEvent(Serial $) {
    //When serial buffer is ready
    println("void serialEvent");
    arduino.serialEvent();
}


void keyPressed() {
    //Handle keyboard
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
        //Check for button clicked
        for (Button button : ButtonList) {
            if (button.getButtonHover()) {
                button.setIsClicked(true);
                break;
            }
        }
        
        //check for textfield readyToActivate
        for (TextField textField : FieldList) {
            textField.mousePressed();
        }
        
        dv.mousePressed(); //inform dataview that mouse is pressed
        
    } else if (mouseButton ==  CENTER) {
        dv.mouseCenter(); //Toggle coordinates
    }
}


void mouseReleased() {
    //When mouse buttons are realeased
    if (mouseButton == LEFT) {

        //Check for button click
        for (Button button : ButtonList) {
            if (button.getButtonHover() && button.getButtonStatus()) {
                button.setIsClicked(false);
                orc.handleButton(button.getButtonID());
                break;
            }
        }
        
        //Activate or deactivate textfields
        for (TextField textField : FieldList) {
            textField.mouseReleased();
        }
        
        dv.mouseReleased();
    }
}


void mouseDragged() {
    //Dragged = mouse pressed and moved
    if (mouseButton == LEFT) {
        //print("Dragged");
        dv.mouseDragged(); //<>//
    }
}


void mouseWheel(MouseEvent event) {
    //Scroolwheel on mouse
    dv.mouseWheel(event);
}


void windowResized() {
    //println("RESIZE");

    //Resize all layers
    for (int i = 0; i < layers.length; i++) {
        layers[i] = createGraphics(width, height);
    }

    //REsize alle UIcomponents
    screen.setComponentSize(width, height);
    screen.rescaleChildren();
}
