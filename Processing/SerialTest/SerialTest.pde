import processing.serial.*;

Serial myPort;  
String inString;
String text = "";

boolean newData = false;

void setup() {
    size(1080, 720);
    printArray(Serial.list());
    myPort = new Serial(this, Serial.list()[0], 9600);
    myPort.bufferUntil('!');
    textSize(20);
}

void draw() {
    background(100); 
    text(text, 10, 100);
    text("buffer: " + inString + " as String", 10,50);

    if (newData) {
        inString += myPort.readChar();
        newData = false;
    }
}

void serialEvent(Serial p) {
    inString = p.readString();
    newData = true;
}



void keyPressed() {
    if (key == ENTER) {
        myPort.write(text); 
        text = "";
    } else{
        text += key;
    }
}