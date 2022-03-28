//import java.util.Map;

String text = "";
HashMap<String, ArrayList> dataMap = new HashMap<String, ArrayList>();

DataPoint dp = new DataPoint(1, 1, 1);
ArrayList<DataPoint> al = new ArrayList<DataPoint>();

void setup() {
    size(1920, 1080);
    textSize(40);
    
    
    
    al.add(dp);
    dataMap.put("1,1", al);
}

void draw() {
    background(100); 
    text(dataMap, 10, 100);
}

void keyPressed() {
    if (key == ENTER) {
        text = "";
    } else if (key == CODED) {
        
    } else if (key == BACKSPACE) {
        text = text.substring(0, text.length() - 1);
    } else{
        text += key;
    }
}

class DataPoint {
    int xpos, ypos;
    float angle;
    
    DataPoint(int xpos, int ypos, float angle) {
        this.xpos = xpos;
        this.ypos = ypos;
        this.angle = angle;
    }
}