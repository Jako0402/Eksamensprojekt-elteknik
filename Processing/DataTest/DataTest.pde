//import java.util.Map;
//import java.util.List;

String text = "";
int rotation = 0;
HashMap<String, ArrayList<DataPoint>> dataMap = new HashMap<String, ArrayList<DataPoint>>();
boolean obstacle = true;

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
    println(key);
    
    DataPoint dpToAdd = new DataPoint(xpos, ypos, angle, obstacle);
    
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
        keyDoStuff();
        text = "";
    } else if (key == CODED) {
        if (keyCode  == CONTROL) obstacle = !obstacle;
    } else if (key == BACKSPACE) {
        text = text.substring(0, text.length() - 1);
    } else{
        text += key;
    }
}


void keyDoStuff() {
    String toParse = text.toLowerCase();
    println(toParse);
    if (match(toParse, "clear") != null) {
        println("clear");
        dataMap = new HashMap<String, ArrayList<DataPoint>>();
    }
}


void mouseWheel(MouseEvent event) {
    //https://processing.org/reference/mouseWheel_.html
    int e = event.getCount();
    //1 = mod bruger
    //-1 = væk fra bruger
    //println(e);
    if (e > 0) {
        rotation += 10;
        if (rotation > 350) rotation = 0;
    } else{
        rotation -= 10;
        if (rotation < 0) rotation = 350;
    }
}


void mousePressed() {
    //print("MOUSE");
    addDataPoint(mouseX / 10, mouseY / 10, rotation);
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

