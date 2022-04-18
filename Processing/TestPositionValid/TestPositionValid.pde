import processing.serial.*;

Serial myPort;  
String inString = "";

float lastX, lastY, lastRot;

void setup() {
    size(1080, 720);
    printArray(Serial.list());
    myPort = new Serial(this, Serial.list()[0], 9600);
    myPort.bufferUntil('!');
    textSize(20);
}


void draw() {
    background(100); 
    text("textFromSerial: " + inString + " as String", 10, 50);
    text("lastX: " + lastX, 10, 100);
    text("lastY: " + lastY, 10, 150);
    text("lastRot: " + lastRot, 10, 200);


    pushMatrix();
    translate(width/2, height/2);
    circle(lastX, lastY, 20);
    popMatrix();

    
}


void serialEvent(Serial p) {
    inString = p.readString();
    inString = inString.substring(0, inString.length() - 1);
    String[] splitData = split(inString, ';');
    
    if (splitData.length != 3) return;
    lastX = float(splitData[0]);
    lastY = float(splitData[1]);
    lastRot = float(splitData[2]);
}

