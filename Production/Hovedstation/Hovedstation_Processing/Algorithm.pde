class DataPoint {
    int xpos, ypos;
    int angle;
    boolean obstacle;
    
    DataPoint(int xpos, int ypos, int angle, boolean obstacle) {
        this.xpos = xpos;
        this.ypos = ypos;
        this.angle = angle;
        this.obstacle = obstacle;
    }
    
    
    public int getXpos() {
        return xpos;
    }
    
    
    public int getYpos() {
        return ypos;
    }
    
    
    public int getAngle() {
        return angle;
    }
    
    
    public boolean getObstacle() {
        return obstacle;
    }
}


class Storage {
    HashMap<String, ArrayList<DataPoint>> dataPointListMap;
    int cellResolution = 10; //Size of Hashmap key resolution
    
    Storage() {
        dataPointListMap = new HashMap<String, ArrayList<DataPoint>>();
    }
    
    
    public void addDataPointToStorage(DataPoint dp) {
        //Takes a datoPoint and adds it to appropriate cell / ArrayList
        int xKey = dp.getXpos() / cellResolution;
        int yKey = dp.getYpos() / cellResolution;
        String key = str(xKey) + "," + str(yKey); //Key is "cell x-number","cell y-number"
        ArrayList dataPointList = dataPointListMap.get(key); 
        
        if (dataPointList == null) {
            //println("Point placed in empty cell");
            
            ArrayList<DataPoint> newArrayListWithDP = new ArrayList<DataPoint>();
            newArrayListWithDP.add(dp);
            dataPointListMap.put(key, newArrayListWithDP);
        } else{
            //println("Point placed in existing cell")
            dataPointList.add(dp);
        }
    }
    
    
    public ArrayList<DataPoint> getDataPointArrayList(String key) {
        return dataPointListMap.get(key); 
    }
    
    
    public int getCellResolution() {
        return cellResolution;
    }
    
    
    public String[] getNeighbors(String centerKey, int radius) {
        //Takes a key, and a radius. Returns a string array of all neighbors
        String[] foundNeighbors = {};
        
        //Splitting the string and parse to int
        String[] keys = split(centerKey, ',');
        int[] keysAsInt = {int(keys[0]), int(keys[1])};
        
        //Find all neighbors in radius
        for (int xSearch = -radius; xSearch <= radius; xSearch++) {
            for (int ySearch = -radius; ySearch <= radius; ySearch++) {
                String xKey = str(keysAsInt[0] + xSearch);
                String yKey = str(keysAsInt[1] + ySearch);
                println("Neighbor: " + xKey + "," + yKey);
                foundNeighbors = append(foundNeighbors, xKey + "," + yKey);
            }
        }
        
        return foundNeighbors;
    }
    
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    
}


class Algorithm {
    Algorithm() {
        
    }


    public int[] calculateTarget() {
        
    }
}


class VehicleController {
    Algorithm algorithm;
    Storage storage;
    int[] lastPosition = {0, 0}; //Last update from vehicle
    
    VehicleController(Algorithm algorithm, Storage storage) {
        this.algorithm = algorithm;
        this.storage = storage;
    }
}