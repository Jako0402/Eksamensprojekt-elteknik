import processing.serial.*;

Serial myPort;  
String inString;
String text = "";

void setup() {
    size(1080, 720);
    printArray(Serial.list());
    myPort = new Serial(this, Serial.list()[0], 9600);
    myPort.bufferUntil(33);
    textSize(20);
}

void draw() {
    background(100); 
    text("received: " + inString + "as String", 10,50);
    text(text, 10, 100);
}

void serialEvent(Serial p) {
    inString = p.readString();
}


void keyPressed() {
    if (key == ENTER) {
        myPort.write(text); 
        text = "";
    } else{
        text += key;
    }
}