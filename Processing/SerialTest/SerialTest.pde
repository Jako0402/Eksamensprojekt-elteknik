import processing.serial.*;

Serial myPort;  

String inString;
String text = "";
boolean newData = false;
int[] expectedDataLengthArray = {3, 2, 3};

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
        println("checkData: " + checkData(inString));
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

/* 
0 = Valid package
1 = Fist char is not ´?´ 
2 = CommandID not number
3 = ';' not found
4 = '!' not found
5 = Wrong checksum
*/
int checkData(String stringToCheck) {
    println("Check: " + stringToCheck);
    int index = 0;
    if (stringToCheck.charAt(index) != '?') return 1; //Check first char
    index++;
    
    String commandIDStr = str(stringToCheck.charAt(index));
    if (!isInt(commandIDStr)) return 2;
    int commandID = int(commandIDStr);
    
    int expectedDataLength = expectedDataLengthArray[commandID];
    //println("expectedDataLength: " + expectedDataLength);
    
    
    for (int i = 0; i < expectedDataLength; i++) {
        //println("number: " + i);
        index++;
        if (stringToCheck.charAt(index) != ';') return 3;
        index++;
        
        while(true) {
            String currentIntStr = str(stringToCheck.charAt(index));
            //println("currentIntStr: " + currentIntStr);
            if (isInt(currentIntStr)) {
                index++;
            } else{
                index--;
                break;
            }
        }
    }
    
    index++;
    if (stringToCheck.charAt(index) != '!') return 4;
    
    String checkSumString = stringToCheck.substring(0, stringToCheck.length()-1);
    byte expectedCS = 0;
    //https://forum.processing.org/beta/num_1274186375.html
    for (char toAdd : checkSumString.toCharArray()) {
        //println(toAdd);
        expectedCS += int(toAdd);
    }


    index++;
    println("expectedCS: " + char(expectedCS));
    println("receivedCS: " + stringToCheck.charAt(index));
    if (stringToCheck.charAt(index) != char(expectedCS)) return 5;


    return 0;
}

//https://www.baeldung.com/java-check-string-number
boolean isInt(String testStr) {
    if (testStr == null) {
        return false;
    }
    try {
        int testInt = Integer.parseInt(testStr);
    } catch(NumberFormatException e) {
        return false;
    }
    return true;
}