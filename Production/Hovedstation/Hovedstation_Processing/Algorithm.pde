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


class WallSegment {
    int x1, y1, x2, y2;
    
    WallSegment(int x1, int y1, int x2, int y2) {
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
    }
    
    
    public int[] getPoint1() {
        return new int[]{x1, y1};
    }
    
    
    public int[] getPoint2() {
        return new int[]{x2, y2};
    }
    
}


class Storage {
    HashMap<String, ArrayList<DataPoint>> dataPointListMap;
    ArrayList<WallSegment> wallsList;
    DataPoint lastDataPoint;
    DataPoint lastObstacle;
    int[] currentTarget = {0, 0};
    int cellResolution = 10; //Size of Hashmap key resolution
    
    Storage() {
        dataPointListMap = new HashMap<String, ArrayList<DataPoint>>();
        wallsList = new ArrayList<WallSegment>();
        addDataPointToStorage(new DataPoint(0, 0, 0, false)); //0,0 is always free
    }
    
    
    public void addDataPointToStorage(DataPoint dp) {
        //Takes a datoPoint and adds it to appropriate cell / ArrayList
        
        updateLastSave(dp);
        
        int[] dpKey = getDataPointKey(dp);
        String key = str(dpKey[0]) + "," + str(dpKey[1]); //Key is "cell x-number","cell y-number"
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
    
    
    public void addWalls(ArrayList<WallSegment> wallsToAdd) {
        for (WallSegment segment : wallsToAdd) {
            wallsList.add(segment);
        }
    }
    
    
    public ArrayList<WallSegment> getWallsList() {
        return wallsList;
    }
    
    
    public ArrayList<DataPoint> getDataPointArrayList(String key) {
        return dataPointListMap.get(key); 
    }
    
    
    public HashMap<String, ArrayList<DataPoint>> getDataPointListMap() {
        return dataPointListMap; 
    }
    
    
    public int getCellResolution() {
        return cellResolution;
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
                //println("Neighbor: " + xKey + "," + yKey);
                foundNeighbors = append(foundNeighbors, xKey + "," + yKey);
            }
        }
        
        return foundNeighbors;
    }
    
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    private void updateLastSave(DataPoint dpToAdd) {
        lastDataPoint = dpToAdd;
        if (dpToAdd.getObstacle()) lastObstacle = dpToAdd;
    }
    
    
    private int[] getDataPointKey(DataPoint dp) {
        int xKey = dp.getXpos() / cellResolution;
        int yKey = dp.getYpos() / cellResolution;
        return new int[]{xKey, yKey};
    }
}


class Algorithm {
    //Pass a subclass of 'Algorithm' to a 'VehicleController'
    Algorithm() {}
    
    
    public int[] calculateTarget(ArrayList<DataRequest> requestedDataPackage) {
        return null; 
    }
    
    
    public ArrayList<WallSegment> calculateWallSegment(ArrayList<DataRequest> requestedDataPackage) {
        return null;
    }
    
    
    public ArrayList<DataRequest> requestTargetData() {
        //Returns an arraylist with needed data to calculate next target
        ArrayList<DataRequest> requestedDataPackage = new ArrayList<DataRequest>();
        return requestedDataPackage;
    }
    
    
    public ArrayList<DataRequest> requestWalltData() {
        //Returns an arraylist with needed data to calculate next target
        ArrayList<DataRequest> requestedDataPackage = new ArrayList<DataRequest>();
        return requestedDataPackage;
    }
    
}


class WallFollowAlgorithm extends Algorithm {
    HashMap<String, ArrayList<DataPoint>> dataPointListMap;
    int[] lastPosition = {0,0};
    int[] lastObstacle = {0,0};
    int lastObstacleAngle = 0;
    String[] lastNeighbors;
    
    WallFollowAlgorithm() {}
    
    
    @Override
    public int[] calculateTarget(ArrayList<DataRequest> requestedDataPackage) {
        unpackTargetDataPackage(requestedDataPackage);
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
    public ArrayList<WallSegment> calculateWallSegment(ArrayList<DataRequest> requestedDataPackage) {
        unpackWallDataPackage(requestedDataPackage);
        
        ArrayList<WallSegment> wsToAdd = new ArrayList<WallSegment>();
        for (String neighborKey : lastNeighbors) { //Loop through all neihbors
            if (neighborKey == "") continue;
            ArrayList<DataPoint> dataPointAL = dataPointListMap.get(neighborKey); //Get Arraylist with datapoint in current cell
            if (dataPointAL == null) continue; //No list = no potential wall = go to next neighbor
            
            for (DataPoint dpElement : dataPointAL) { //If a cell hsa points, loop through all points
                if ((dpElement.getAngle() - lastObstacleAngle) < 20 && dpElement.getObstacle()) { 
                    wsToAdd.add(new WallSegment(dpElement.getXpos(), dpElement.getYpos(), 
                        lastObstacle[0], lastObstacle[1]));        
                }
            }
        }
        return wsToAdd;
    }
    
    
    @Override
    public ArrayList<DataRequest> requestTargetData() {
        ArrayList<DataRequest> requestedDataPackage = super.requestTargetData();
        requestedDataPackage.add(new DataRequest(Requests.get("lastPosition")));
        requestedDataPackage.add(new DataRequest(Requests.get("lastObstacle")));
        requestedDataPackage.add(new DataRequest(Requests.get("lastObstacleAngle")));
        return requestedDataPackage;
    }
    
    
    @Override
    public ArrayList<DataRequest> requestWalltData() {
        //Returns an arraylist with needed data to calculate next target
        ArrayList<DataRequest> requestedDataPackage = super.requestTargetData();
        String extraData = str(lastObstacle[0] / 10) + "," + str(lastObstacle[1] / 10) + ";" + str(2);
        println("extraData: " + extraData);
        requestedDataPackage.add(new DataRequest(Requests.get("neighborKeys")).setExtraData(extraData));
        requestedDataPackage.add(new DataRequest(Requests.get("dataPointListMap")));
        requestedDataPackage.add(new DataRequest(Requests.get("lastObstacle")));
        requestedDataPackage.add(new DataRequest(Requests.get("lastObstacleAngle")));
        
        return requestedDataPackage;
    }
    
    
    private boolean unpackTargetDataPackage(ArrayList<DataRequest> requestedDataPackage) {
        //Returns true if unpacked successfully
        if (requestedDataPackage.size() != 4) return false;
        
        lastPosition = (int[])requestedDataPackage.get(0).getData();
        lastObstacle = (int[])requestedDataPackage.get(1).getData();
        lastObstacleAngle = (Integer)requestedDataPackage.get(2).getData();
        
        return true;
    }
    
    
    private boolean unpackWallDataPackage(ArrayList<DataRequest> requestedDataPackage) {
        if (requestedDataPackage.size() != 4) return false;
        lastNeighbors = (String[])requestedDataPackage.get(0).getData();
        dataPointListMap = (HashMap<String, ArrayList<DataPoint>>)requestedDataPackage.get(1).getData();
        lastObstacle = (int[])requestedDataPackage.get(2).getData();
        lastObstacleAngle = (Integer)requestedDataPackage.get(3).getData();
        return true;
    }
}






class VehicleController {
    Algorithm algorithm;
    Storage storage;
    ComDevice arduino;
    int[] lastCommandContent;
    int lastCommandID;
    
    
    VehicleController(Algorithm algorithm, Storage storage, ComDevice arduino) {
        this.algorithm = algorithm;
        this.storage = storage;
        this.arduino = arduino;
    }
    
    
    public void update() {
        //called every frame
        arduino.update();
    }
    
    
    public void resendLastCommand() {
        arduino.sendCommand(lastCommandID, lastCommandContent);
    }
    
    
    public int[]generateNewTarget() {
        ArrayList<DataRequest> requiredData = algorithm.requestTargetData();
        requiredData = fulfillDataRequest(requiredData);
        int[] target = algorithm.calculateTarget(requiredData);
        storage.setCurrentTarget(target);
        return target;
    }
    
    
    public ArrayList<WallSegment> generateWallSegments() {
        ArrayList<DataRequest> requiredData = algorithm.requestWalltData();
        requiredData = fulfillDataRequest(requiredData);
        ArrayList<WallSegment> walls = algorithm.calculateWallSegment(requiredData);
        return walls;
    }
    
    
    public boolean driveToTarget(int[] target) {
        if (target.length != 2) return false;
        arduino.sendCommand(1, new int[]{target[0], target[1]});
        lastCommandID = 1;
        lastCommandContent = target;
        return true;
    }
    
    
    public void addWallSegmentsToStorage(ArrayList<WallSegment> wallsToAdd) {
        storage.addWalls(wallsToAdd);
    }
    
    
    public void stopVehicle() {
        arduino.sendCommand(2, new int[]{});
        lastCommandID = 2;
        lastCommandContent = new int[]{};
    }
    
    
    public void requestArduinoStatus() {
        arduino.sendCommand(0, new int[]{});
        lastCommandID = 0;
        lastCommandContent = new int[]{};
    }
    
    
    public int getArduinoReponseStatus() {
        return this.arduino.getReponseStatus();
    }
    
    
    public void setArduinoReponseStatus(int responseStatus) {
        this.arduino.setReponseStatus(responseStatus);
    }
    
    
    public int[]getArduinoReponseData() {
        return this.arduino.getReponseData();
    }
    
    
    public void setTargetInStorage(int[] currentTarget) {
        storage.setCurrentTarget(currentTarget);
    }
    
    
    public void addDataPointToStorage(DataPoint dpToAdd) {
        storage.addDataPointToStorage(dpToAdd);
    }
    
    
    public String[] exportDataPoints() {
        String[] exportedData = {};
        
        for (ArrayList < DataPoint > dataPointList : storage.getDataPointListMap().values()) {
            for (DataPoint CurrentDataPoint : dataPointList) {
                int dpXpos = CurrentDataPoint.getXpos();
                int dpYpos = CurrentDataPoint.getYpos();
                int dpAngle = CurrentDataPoint.getAngle();
                int dpObstacle = CurrentDataPoint.getObstacle() ? 1 : 0; 
                String dataLine = str(dpXpos) + ";" + str(dpYpos) + ";" + str(dpAngle) + ";" + str(dpObstacle); 
                exportedData = append(exportedData, dataLine);
                //println(dataLine);
            }
        }
        
        return exportedData;
    }
    
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    private ArrayList<DataRequest> fulfillDataRequest(ArrayList<DataRequest> request) {
        for (DataRequest dr : request) {
            int requestID = dr.getID();
            //println("requestID: " + requestID);
            switch(requestID) {
                case 0:
                    dr.setData(this.storage);
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
                
                case 4:
                    dr.setData(fulfullRequest4(dr));
                    break;
                
                case 5:
                    dr.setData(fulfullRequest5(dr));
                    break;
                
                case 6:
                    dr.setData(fulfullRequest6());
                    break;
                
                default:
                println("ERROR DataRequest not found; Returnning empty data object");
                break;
                
                
            }
        }
        
        return request;
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
            //Ifno obstacle is encountered yew
            return new int[]{0,0};
        }
    }
    
    
    private int fulfullRequest3() {
        //Returns last obstacle angle
        try {
            return storage.getLastObstacle().getAngle();
        } catch(Exception e) {
            //Ifno obstacle is encountered yew
            return 0;
        }
    }
    
    
    private String[] fulfullRequest4(DataRequest request) {
        String extraData = request.getExtraData(); //key;radius (eg. 12,3;4)
        String[] splitExtraData = split(extraData, ';');
        String[] foundNeighbors = storage.getNeighbors(splitExtraData[0], int(splitExtraData[1]));
        return foundNeighbors;
    }
    
    
    private ArrayList<DataPoint> fulfullRequest5(DataRequest request) {
        //getDataPointArrayList
        String extraData = request.getExtraData(); //key (eg. 12,3)
        ArrayList<DataPoint> dataPointArrayList = storage.getDataPointArrayList(extraData);
        return dataPointArrayList;
    }
    
    
    private HashMap<String, ArrayList<DataPoint>> fulfullRequest6() {
        return storage.getDataPointListMap();
    }
}


class DataRequest {
    //Objectcarrying a request and the returned data
    int requestID;
    String extraData;
    Object requestedData;
    
    
    DataRequest(int requestID) {
        this.requestID = requestID;
    }
    
    
    public int getID() {
        return requestID;
    }
    
    
    public Object getData() {
        return requestedData;
    }
    
    public String getExtraData() {
        return extraData;
    }
    
    
    public void setData(Object requestedData) {
        this.requestedData = requestedData;
        return;
    }
    
    
    public DataRequest setExtraData(String extraData) {
        this.extraData = extraData;
        return this;
    }
}
