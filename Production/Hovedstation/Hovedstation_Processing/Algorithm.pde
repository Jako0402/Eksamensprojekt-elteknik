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
    DataPoint lastDataPoint;
    DataPoint lastObstacle;
    int[] currentTarget = {0, 0};
    int cellResolution = 10; //Size of Hashmap key resolution
    
    Storage() {
        dataPointListMap = new HashMap<String, ArrayList<DataPoint>>();
        addDataPointToStorage(new DataPoint(0, 0, 0, false)); //0,0 is always free
    }
    
    
    public void addDataPointToStorage(DataPoint dp) {
        //Takes a datoPoint and adds it to appropriate cell / ArrayList
        
        updateLastSave(dp);
        
        int xKey = dp.getXpos() / cellResolution;
        int yKey = dp.getYpos() / cellResolution;
        String key = str(xKey) + "," + str(yKey); //Key is "cell x-number","cell y-number"
        ArrayList dataPointList = getDataPointArrayList(key); 
        
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
    
    
    public DataPoint getLastDataPoint() {
        return lastDataPoint;
    }
    
    
    public DataPoint getLastObstacle() {
        return lastObstacle;
    }


    public void setCurrentTarget(int[] currentTarget) {
        this.currentTarget = currentTarget;
    }


    public int[] getCurrentTarget() {
        return currentTarget;
    }
    
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    private void updateLastSave(DataPoint dpToAdd) {
        lastDataPoint = dpToAdd;
        if (dpToAdd.getObstacle()) lastObstacle = dpToAdd;
    }
}


class Algorithm {
    //Pass a subclass of 'Algorithm' to a 'VehicleController'
    Algorithm() {}
    
    
    public int[] calculateTarget(ArrayList<dataRequest> requestedDataPackage) {
        return null; 
    }
    
    
    public ArrayList<dataRequest> requestData() {
        //Returns an arraylist with needed data to calculate next target
        ArrayList<dataRequest> requestedDataPackage = new ArrayList<dataRequest>();
        return requestedDataPackage;
    }
}


class WallFollowAlgorithm extends Algorithm {
    int[] lastPosition;
    int[] lastObstacle;
    int lastObstacleAngle;
    
    
    WallFollowAlgorithm() {}
    
    
    @Override
    public int[] calculateTarget(ArrayList<dataRequest> requestedDataPackage) {
        unpackDataPackage(requestedDataPackage);
        println("calculate new taget"); //Back
        int[] target = {0, 0};
        if (lastPosition[0] / 10 == lastObstacle[0] / 10 && lastPosition[1] / 10 == lastObstacle[1] / 10) {
            println("Same square ");
            float dx = 15 * sin(lastObstacleAngle * (PI / 180));
            float dy = 15 * cos(lastObstacleAngle * (PI / 180));
            println("dx: " + dx + " - dy: " + dy);
            
            target[0] = lastObstacle[0] + int( -dx);
            target[1] = lastObstacle[1] + int( -dy);
        } else if (dist(lastPosition[0], lastPosition[1], lastObstacle[0], lastObstacle[1]) < 30) { //Along
            float newAngle = lastObstacleAngle + 90;
            float dx = 30 * sin(newAngle * (PI / 180));
            float dy = 30 * cos(newAngle * (PI / 180));
            println("dx: " + dx + " - dy: " + dy);
            
            target[0] = lastPosition[0] + int( -dx);
            target[1] = lastPosition[1] + int( -dy);
        } else{ //Foreward
            float newAngle = lastObstacleAngle - 90;
            float dx = 30 * cos(newAngle * (PI / 180));
            float dy = 30 * sin(newAngle * (PI / 180));
            println("dx: " + dx + " - dy: " + dy);
            
            target[0] = lastPosition[0] + int(dx);
            target[1] = lastPosition[1] + int( -dy);  
        }
        
        return target;
    }
    
    
    @Override
    public ArrayList<dataRequest> requestData() {
        ArrayList<dataRequest> requestedDataPackage = super.requestData();
        requestedDataPackage.add(new dataRequest(Requests.get("lastPosition")));
        requestedDataPackage.add(new dataRequest(Requests.get("lastObstacle")));
        requestedDataPackage.add(new dataRequest(Requests.get("lastObstacleAngle")));
        return requestedDataPackage;
    }
    
    
    private boolean unpackDataPackage(ArrayList<dataRequest> requestedDataPackage) {
        //Returns true if unpacked successfully
        if (requestedDataPackage.size() != 3) return false;
        
        lastPosition = (int[])requestedDataPackage.get(0).getData();
        lastObstacle = (int[])requestedDataPackage.get(1).getData();
        lastObstacleAngle = (Integer)requestedDataPackage.get(2).getData();
        
        return true;
    }
}


class VehicleController {
    Algorithm algorithm;
    Storage storage;
    ComDevice arduino;
    
    
    VehicleController(Algorithm algorithm, Storage storage, ComDevice arduino) {
        this.algorithm = algorithm;
        this.storage = storage;
        this.arduino = arduino;
    }
    
    
    public int[] generateNewTarget() {
        ArrayList<dataRequest> requiredData = algorithm.requestData();
        requiredData = fulfillDataRequest(requiredData);
        int[] target = algorithm.calculateTarget(requiredData);
        storage.setCurrentTarget(target);
        return target;
    }
    
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    private ArrayList<dataRequest> fulfillDataRequest(ArrayList<dataRequest> request) {
        for (dataRequest dr : request) {
            int requestID = dr.getID();
            //println("requestID: " + requestID);
            switch(requestID) {
                case 0:
                    dr.setData(fulfullRequest0());
                    break;
                
                case 1:
                    dr.setData(fulfullRequest1());
                    break;
                
                case 2:
                    dr.setData(fulfullRequest2());
                    break;
                
                
                case 3:
                    dr.setData(fulfullRequest3());
                    break;
                
                default:
                println("ERROR dataRequest not found; Returnning empty data object");
                break;
                
                
            }
        }
        
        return request;
    }
    
    
    private Storage fulfullRequest0() {
        //Returns a reference to storage object
        return storage;
    }
    
    
    private int[] fulfullRequest1() {
        //Returns last vehicle position
        int lastXpos = storage.getLastDataPoint().getXpos();
        int lastYpos = storage.getLastDataPoint().getYpos();
        return new int[]{lastXpos, lastYpos};
    }
    
    
    private int[] fulfullRequest2() {
        //Returns last obstacle position
        try {
            int lastXpos = storage.getLastObstacle().getXpos();
            int lastYpos = storage.getLastObstacle().getYpos();
            return new int[]{lastXpos, lastYpos};
        } catch(Exception e) {
            //If no obstacle is encountered yew
            return new int[]{0,0};
        }
    }
    
    
    private int fulfullRequest3() {
        //Returns last obstacle angle
        try {
            return storage.getLastObstacle().getAngle();
        } catch(Exception e) {
            //If no obstacle is encountered yew
            return 0;
        }
    }
}


class dataRequest {
    int requestID;
    Object requestedData;
    
    
    dataRequest(int requestID) {
        this.requestID = requestID;
    }
    
    
    public int getID() {
        return requestID;
    }
    
    
    public Object getData() {
        return requestedData;
    }
    
    
    public void setData(Object requestedData) {
        this.requestedData = requestedData;
    }
}
