class DataPoint {
    //Class that contains data for one data / response fron vehicle
    int xpos, ypos; //coordinaes (in cm)
    int angle; //degrees
    boolean obstacle; //true = obstacle detected
    
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
    //Holds data for calculated wallsegments as two endpoints
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
    //Holds all datapoints, walls and references to last datapoints
    HashMap<String, ArrayList<DataPoint>> dataPointListMap;
    ArrayList<WallSegment> wallsList;
    DataPoint lastDataPoint;
    DataPoint lastObstacle;
    int[] currentTarget = {0, 0}; //Where vehicle is heading
    int cellResolution = 10; //Size of Hashmap key resolution
    
    Storage() {
        dataPointListMap = new HashMap<String, ArrayList<DataPoint>>();
        wallsList = new ArrayList<WallSegment>();
        addDataPointToStorage(new DataPoint(0, 0, 0, false)); //0,0 is always free 
    }
    
    
    public void addDataPointToStorage(DataPoint dp) {
        //Takes a datoPoint and adds it to appropriate cell / ArrayList
        
        updateLastSave(dp); //Updates 'lastDataPoint' and 'lastObstacle'
        
        int[] dpKey = getDataPointKey(dp); //Datapoint key as int[2] (eg. [2,3])
        String key = str(dpKey[0]) + "," + str(dpKey[1]); //Key is "cell x-number","cell y-number" (eg. 2,3)
        ArrayList dataPointList = getDataPointArrayList(key); 
        
        //Add datapoint to 'dataPointListMap'. Create new Arraylist if none exists
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
        //Takes an ArrayList with WallSegments and adds all to wallsList
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
        String[] keys = split(centerKey, ','); //2,3 --> ["2", "3"]
        int[] keysAsInt = {int(keys[0]), int(keys[1])}; //["2", "3"] --> [2, 3]
        
        //Find all neighbors in radius
        for (int xSearch = -radius; xSearch <= radius; xSearch++) {
            for (int ySearch = -radius; ySearch <= radius; ySearch++) {
                String xKey = str(keysAsInt[0] + xSearch); //Add current cell difference to center key
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
        //Sets newsets datapoint as latest
        lastDataPoint = dpToAdd;
        if (dpToAdd.getObstacle()) lastObstacle = dpToAdd;
    }
    
    
    private int[] getDataPointKey(DataPoint dp) {
        //Takes a dataPoint and returns the key as int[xkey, ykey]
        int xKey = dp.getXpos() / cellResolution;
        int yKey = dp.getYpos() / cellResolution;
        return new int[]{xKey, yKey};
    }
}


class Algorithm {
    //Pass a subclass of 'Algorithm' to a 'VehicleController'
    //Users can write a other angorithms. The methods are called in following order
    //requestTargetData()       Returns an ArrayList with DataRequests
    //calculateTarget()         Takes an ArrayList with full DataRequests and returns target as int[x, y] 
    //requestWalltData()        Returns an ArrayList with DataRequests
    //calculateWallSegment()    Takes an ArrayList with full DataRequests and returns an Arraylist with WallSegments
    //NOTE: The Algorithm-objetcs are NOT ment to be destroyed / they can hold presistant variables
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
    //A simple algorithm that follows walls
    //Below: Extra variables this algorihm requires
    HashMap<String, ArrayList<DataPoint>> dataPointListMap;
    int[] lastPosition = {0,0};
    int[] lastObstacle = {0,0};
    int lastObstacleAngle = 0;
    String[] lastNeighbors;
    int neighborSearchLength;
    
    WallFollowAlgorithm(int neighborSearchLength) {
        this.neighborSearchLength = neighborSearchLength;
    } 
    
    
    @Override
    public int[] calculateTarget(ArrayList<DataRequest> requestedDataPackage) {
        unpackTargetDataPackage(requestedDataPackage);
        println("calculate new taget"); //Back
        int[] target = {0, 0};
        if (lastPosition[0] / 10 == lastObstacle[0] / 10 && lastPosition[1] / 10 == lastObstacle[1] / 10) {
            println("Same square ");
            float dx = 15 * sin(lastObstacleAngle * (PI / 180));
            float dy = 15 * cos(lastObstacleAngle * (PI / 180));
            //println("dx: " + dx + " - dy: " + dy);
            
            target[0] = lastObstacle[0] + int( -dx);
            target[1] = lastObstacle[1] + int( -dy);
        } else if (dist(lastPosition[0], lastPosition[1], lastObstacle[0], lastObstacle[1]) < 30) { //Along
            float newAngle = lastObstacleAngle + 90;
            float dx = 30 * sin(newAngle * (PI / 180));
            float dy = 30 * cos(newAngle * (PI / 180));
            //println("dx: " + dx + " - dy: " + dy);
            
            target[0] = lastPosition[0] + int( -dx);
            target[1] = lastPosition[1] + int( -dy);
        } else{ //Foreward
            float newAngle = lastObstacleAngle - 90;
            float dx = 30 * cos(newAngle * (PI / 180));
            float dy = 30 * sin(newAngle * (PI / 180));
            //println("dx: " + dx + " - dy: " + dy);
            
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
                //println("angles: " + dpElement.getAngle() + "  " + lastObstacleAngle);
                if (abs(dpElement.getAngle() - lastObstacleAngle) < 20 && dpElement.getObstacle()) { 
                    wsToAdd.add(new WallSegment(dpElement.getXpos(), dpElement.getYpos(), 
                        lastObstacle[0], lastObstacle[1]));        
                }
            }
        }
        return wsToAdd;
    }
    
    
    @Override
    public ArrayList<DataRequest> requestTargetData() {
        //This algorithm needs lastPosition, lastObstacle, lastObstacleAngle
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

        //neighborKeys needs the field 'extraData' to know centerKey and 
        String extraData = str(lastObstacle[0] / 10) + "," + str(lastObstacle[1] / 10) + ";" + str(neighborSearchLength);
        //println("extraData: " + extraData);
        requestedDataPackage.add(new DataRequest(Requests.get("neighborKeys")).setExtraData(extraData));
        requestedDataPackage.add(new DataRequest(Requests.get("dataPointListMap")));
        requestedDataPackage.add(new DataRequest(Requests.get("lastObstacle")));
        requestedDataPackage.add(new DataRequest(Requests.get("lastObstacleAngle")));
        
        return requestedDataPackage;
    }
    
    
    private boolean unpackTargetDataPackage(ArrayList<DataRequest> requestedDataPackage) {
        //Returns true if unpacked successfully
        if (requestedDataPackage.size() != 4) return false;
        
        //Data is returned as 'Object'. Programmer must know type
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
    //Controls the vehicle by using a ComDevice. Algorithm and Storage used to generete walls and targets
    Algorithm algorithm;
    Storage storage;
    ComDevice arduino;
    int[] lastCommandContent; //Last command send; used to resend command when timeout
    int lastCommandID;
    
    
    VehicleController(Algorithm algorithm, Storage storage, ComDevice arduino) {
        this.algorithm = algorithm;
        this.storage = storage;
        this.arduino = arduino;
    }
    
    
    public void update() {
        //called every frame
        arduino.update(); //Read and parse data from vehicle / arduino
    }
    
    
    public void resendLastCommand() {
        //Called when no answer is recived from vehicle
        arduino.sendCommand(lastCommandID, lastCommandContent);
    }
    
    
    public int[] generateNewTarget() {
        //Genereates a new taget based on points
        ArrayList<DataRequest> requiredData = algorithm.requestTargetData(); //Get Arraylist with requests
        requiredData = fulfillDataRequest(requiredData); //Fufill the requests
        int[] target = algorithm.calculateTarget(requiredData); //Send the fufulled requests back to algorihm object
        storage.setCurrentTarget(target); //Save new taget to storage
        return target;
    }
    
    
    public ArrayList<WallSegment> generateWallSegments() {
        ArrayList<DataRequest> requiredData = algorithm.requestWalltData();
        requiredData = fulfillDataRequest(requiredData);
        ArrayList<WallSegment> walls = algorithm.calculateWallSegment(requiredData);
        return walls;
    }
    
    
    public boolean driveToTarget(int[] target) {
        //Takes a target int[] and commands vehicle. Returns true if array has two elemetns
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
        //Sends stop commands
        arduino.sendCommand(2, new int[]{});
        lastCommandID = 2;
        lastCommandContent = new int[]{};
    }
    
    
    public void requestArduinoStatus() {
        //Send command 0
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
    
    
    public int[] getArduinoReponseData() {
        return this.arduino.getReponseData();
    }
    
    
    public void setTargetInStorage(int[] currentTarget) {
        storage.setCurrentTarget(currentTarget);
    }
    
    
    public void addDataPointToStorage(DataPoint dpToAdd) {
        storage.addDataPointToStorage(dpToAdd);
    }
    
    
    public String[] exportDataPoints() {
        //Exports data to a String[]. One dataPoint pr. element.
        //xpos;ypos;angle;obstacle (int;int;int:bool)
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
        //Takes a ArrayList<DataRequest> and returns ArrayList<DataRequest> but with DataRequest fufilled
        for (DataRequest dr : request) {
            int requestID = dr.getID();
            //println("requestID: " + requestID);
            switch(requestID) { //RequestID = what data to fill
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
        //Returns a list of neigblors
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
        //Returns whole HashMap with data
        return storage.getDataPointListMap();
    }
}


class DataRequest {
    //Objectcarrying a request and the returned data
    int requestID; //ID - See constants.pde for explanation
    String extraData; //Extradata used to carry mere info about request
    Object requestedData; //Data to be returned
    
    
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
