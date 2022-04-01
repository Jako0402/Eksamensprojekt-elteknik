//import java.util.Map;
//import java.util.List;

String text = "";
int rotation = 0;
boolean obstacle = false;
String[] lastNeighbors = {};
HashMap<String, ArrayList<DataPoint>> dataMap = new HashMap<String, ArrayList<DataPoint>>();
ArrayList<SimpleWallSegment> simpleWallList = new ArrayList<SimpleWallSegment>();
int[] lastObs = new int[2];
float lastObsAngle = 0;
int[] lastPos = {0, 0};
int[] target = {0,0};

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
    circle(target[0]*10, target[1]*10, 24);
    
    fill(0);
    text(text, 10, 100);
    text("mouse: " + mouseX / 10 + ", " + mouseY / 10, 10, 200);
    text("roration: " + rotation, 10, 300);
    text("obstacle: " + obstacle, 10, 400);
    text("lastPos: " + lastPos[0] + ", " + lastPos[1], 10, 500);
    text("lastObs: " + lastObs[0] + ", " + lastObs[1], 10, 600);
    text("target: " + target[0] + ", " + target[1], 10, 700);
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
    
    lastNeighbors = findNeighbors(key, 2);
    lastPos[0] = xpos;
    lastPos[1] = ypos;
    
    if (obstacle) {
        addSimpelWall(xpos, ypos, angle);
        lastObs[0] = xpos;
        lastObs[1] = ypos;
        lastObsAngle = angle;
    }
    
    
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


void addSimpelWall(int xpos, int ypos, float angle) {
    
    for (String neighborKey : lastNeighbors) {
        if (neighborKey == "") continue;
        
        ArrayList<DataPoint> dataMapAL = dataMap.get(neighborKey);
        if (dataMapAL == null) continue;
        
        for (DataPoint element : dataMapAL) {
            if (abs(element.angle - angle) < 20 && element.obstacle) {
                
                SimpleWallSegment wallToAdd = new SimpleWallSegment(xpos * 10, ypos * 10, element.xpos, element.ypos);
                println("Wall: " + xpos + " " + ypos + " " + element.xpos + " " + element.ypos);
                simpleWallList.add(wallToAdd);
            }
            
            
        }
        
    }    
}


void drawlastNeighbors() {
    for (String neighborKey : lastNeighbors) {
        if (neighborKey == "") continue;
        String[] keys = split(neighborKey, ',');
        int[] keysAsInt = {int(keys[0]), int(keys[1])};
        fill(0);
        textSize(10);
        text("N", keysAsInt[0] * 100 + 50, keysAsInt[1] * 100 + 20);
        textSize(40);
    }
    
    for (SimpleWallSegment wall : simpleWallList) {
        line(wall.x1, wall.y1, wall.x2, wall.y2);
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


class SimpleWallSegment {
    int x1, y1, x2, y2;
    //ArrayList<DataPoint> obstaclesInModel;
    
    SimpleWallSegment(int x1, int y1, int x2, int y2) {
        //obstaclesInModel = new ArrayList<DataPoint>();
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
        
    }
    
    
}
