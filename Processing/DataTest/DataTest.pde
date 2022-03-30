//import java.util.Map;
//import java.util.List;

String text = "";
int rotation = 0;
HashMap<String, ArrayList<DataPoint>> dataMap = new HashMap<String, ArrayList<DataPoint>>();
boolean obstacle = true;
String[] lastNeighbors = {};
//Demo-test
//DataPoint dp = new DataPoint(1, 1, 1);
//ArrayList<DataPoint> al = new ArrayList<DataPoint>();


void setup() {
    size(1920, 1080);
    textSize(40);
    surface.setResizable(true);
    
    
    //al.add(dp);
    //dataMap.put("1,1", al);
    
    //addDataPoint(-65, -160, 2.0);
    //addDataPoint(65, 160, 2.0);
}

void draw() {
    background(100); 
    drawGrid();
    drawlastNeighbors();
    
    fill(0);
    text(text, 10, 100);
    text(mouseX / 10 + " - " + mouseY / 10, 10, 200);
    text(rotation, 10, 300);
    text("obstacle: " + obstacle, 10, 400);
    
    
}


void drawGrid() {
    for (int i = 0; i < width / 100; i++) {
        for (int j = 0; j < height / 100; j++) {
            String key = str(i) + "," + str(j);
            //println(key);
            ArrayList<DataPoint> dataMapAL = dataMap.get(key);
            
            if (dataMapAL == null) {
                fill(255);
                rect(i * 100, j * 100, 100, 100);
            } else{
                //println(dataMapAL.get(10).getClass().getSimpleName()); Det er et datapoint
                fill(150);
                rect(i * 100, j * 100, 100, 100);
                for (DataPoint element : dataMapAL) {
                    element.display();
                }
            }
        }
    } 
}


void addDataPoint(int xpos, int ypos, float angle) {
    int xKey = xpos / 10;
    int yKey = ypos / 10;
    String key = str(xKey) + "," + str(yKey);
    println("Key: " + key);
    
    lastNeighbors = findNeighbors(key, 3);
    
    DataPoint dpToAdd = new DataPoint(xpos, ypos, angle, obstacle);
    
    ArrayList dataMapAL = dataMap.get(key);
    if (dataMapAL == null) {
        //println("First point in square");
        
        ArrayList<DataPoint> alToAdd = new ArrayList<DataPoint>();
        alToAdd.add(dpToAdd);
        dataMap.put(key, alToAdd);
    } else{
        //println("Existing point in square");
        dataMapAL.add(dpToAdd);
    }
}



void drawlastNeighbors() {
    for (String neighborKey : lastNeighbors) {
        if (neighborKey == "") continue;
        String[] keys = split(neighborKey, ',');
        int[] keysAsInt = {int(keys[0]), int(keys[1])};
        fill(0);
        textSize(10);
        text("N", keysAsInt[0]*100+50, keysAsInt[1]*100+20);
        textSize(40);
    }
}



class DataPoint {
    int xpos, ypos;
    float angle;
    boolean obstacle;
    
    DataPoint(int xpos, int ypos, float angle, boolean obstacle) {
        this.xpos = xpos * 10;
        this.ypos = ypos * 10;
        this.angle = angle;
        this.obstacle = obstacle;
    }
    
    void PrintTest() {
        println("TEST");
    }
    
    void display() {
        if (obstacle) {
            fill(255);
            circle(xpos, ypos, 10);
            float angleRad = angle * (PI / 180);
            translate(xpos, ypos);
            rotate( -angleRad);
            line( -50, 0, 50, 0);
            line(0, 15, 0, 0);
            rotate(angleRad);
            translate( -xpos, -ypos);
        } else{
            fill(0, 255, 0);
            circle(xpos, ypos, 10);
        }
    }
}

