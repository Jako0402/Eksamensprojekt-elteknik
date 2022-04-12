import processing.serial.*;


View screen = new View(0,0,1080,720);
ComDevice arduino = new ComDevice(new Serial(this, Serial.list()[0], 9600)); //Crashes with no Ardunio. Needs rework


void setup() {
    surface.setResizable(true);
    surface.setTitle("Eksamen i El-teknik 2022 - Søren og Jakob");
    size(1080, 720);
    textSize(40);
    
    screen.addChildrenToList(new UIElement[] {
        new Row().addChildrenToList(new UIElement[] {
            new Column()
        })
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
    arduino.serialEvent();
}


void keyPressed() {
    arduino.sendCommand(1, new int[]{100, 200});
}
