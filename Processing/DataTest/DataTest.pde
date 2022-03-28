//import java.util.Map;

String text = "";
HashMap<String, ArrayList> dataMap = new HashMap<String, ArrayList>();

DataPoint dp = new DataPoint(1, 1, 1);
ArrayList<DataPoint> al = new ArrayList<DataPoint>();

void setup() {
    size(1920, 1080);
    textSize(40);
    
    
    
    //al.add(dp);
    //dataMap.put("1,1", al);
    
    //addDataPoint(-65, -160, 2.0);
    //addDataPoint(65, 160, 2.0);
}

void draw() {
    background(100); 
    text(text, 10, 100);
    text(mouseX / 100 + " - " + mouseY / 100, 10, 200);

    for (int i = 0; i < 1920/100; i++) {
        for (int j = 0; j < 1080/100; j++) {
            String key = str(i) + "," + str(j);
            //println(key);
            ArrayList dataMapAL = dataMap.get(key);
            if (dataMapAL == null) {
                rect(i*100, j*100, 100, 100);
            }else{

            }
        }
    } 
}


void addDataPoint(int xpos, int ypos, float angle) {
    int xKey = xpos;
    int yKey = ypos;
    String key = str(xKey) + "," + str(yKey);
    println(key);
    
    DataPoint dpToAdd = new DataPoint(xpos, ypos, angle);
    
    ArrayList dataMapAL = dataMap.get(key);
    if (dataMapAL == null) {
        println("First point in square");
        
        ArrayList<DataPoint> alToAdd = new ArrayList<DataPoint>();
        alToAdd.add(dpToAdd);
        dataMap.put(key, alToAdd);
    } else{
        println("Existing point in square");
        dataMapAL.add(dpToAdd);
    }
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


void mousePressed() {
    //print("MOUSE");
    addDataPoint(mouseX / 100, mouseY / 100, 2.0);
}

class DataPoint {
    int xpos, ypos;
    float angle;
    
    DataPoint(int xpos, int ypos, float angle) {
        this.xpos = xpos;
        this.ypos = ypos;
        this.angle = angle;
    }
    
    void PrintTest() {
        println("TEST");
    }
}
