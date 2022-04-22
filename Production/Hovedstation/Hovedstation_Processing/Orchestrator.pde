class Orchestrator {
    //Controls vehicleController and keeps track commands
    VehicleController vehicleController;
    int timeoutCounter = 0;
    int statusFrequency = 1200; //ms must be larger than timeout
    int lastStatusTime; //ms
    boolean vehicleControllerActive = false; //Is vehicleController running
    boolean vehicleReadyForCommand = true;
    
    
    Orchestrator(VehicleController vehicleController) {
        this.vehicleController = vehicleController;
    }
    
    
    public void update() {
        //called every frame
        vehicleController.update(); //Update vehicleController
        if (vehicleControllerActive) operateVehicle();
    }
    

    public void handleButton(int ButtonID) {
        //Invokes a method bases on 'ButtonsActions' from  Constants.pde
        try {
            this.getClass().getMethod(ButtonActions.get(ButtonID)).invoke(this);
        } catch(Exception e) {
            println("Error button method name: " + e);
        }
    }
    
    
    public void handleField(int FieldID, String fieldText) {
         //Invokes a method bases on 'FieldActions' from  Constants.pde
        try {
            this.getClass().getMethod(FieldActions.get(FieldID), String.class).invoke(this, fieldText);
        } catch(Exception e) {
            println("Error field method name: " + e);
        }
    }
    
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    private void operateVehicle() {
        //Handles response from vehicleController
        int status = vehicleController.getArduinoReponseStatus();
        
        
        if ((millis() - lastStatusTime) > statusFrequency) {
            //Request status timer 
            requestStatus();
        }
        
        
        if (timeoutCounter > 10) {
            //If continious timeout
            println("TOO MANY TIMEOUTS...CODE A FIX HERE");
            timeoutCounter = 0;
        }
        
        
        switch(status) {
            
            case 3:
                //Good response
                handleGoodResponse();
                timeoutCounter = 0;
                break;
            
            case 4:
                case5:
                case6:
                //Timeout and bad read
                vehicleController.resendLastCommand(); //Resend last command and reset timers
                lastStatusTime = millis();
                vehicleReadyForCommand = false;
                timeoutCounter++;
                break;
            
        }
        
        
        if (vehicleReadyForCommand && vehicleControllerActive) {
            //If active and ready for new command = vehicle has hit obsticale
            generateAndDriveToTarget();
        }
    }
    
    
    private void generateAndDriveToTarget() {
        //Generate a new taget based on storage and send target to vehicle
        vehicleController.driveToTarget(vehicleController.generateNewTarget());
        lastStatusTime = millis(); //reset counter for status update
        ArrayList<WallSegment> newWalls = vehicleController.generateWallSegments();
        vehicleController.addWallSegmentsToStorage(newWalls);
        vehicleReadyForCommand = false; //While we wait for response
    }
    
    
    private void handleGoodResponse() {
        //Ready resonse
        int[] responseData = vehicleController.getArduinoReponseData();
        vehicleController.setArduinoReponseStatus(0); //We have read response; we are no longer expecting a response
        
        switch(responseData[0]) {
            case 0:
                println("vehicle status update");
                vehicleReadyForCommand = !(responseData[4] == 0);
                //Add dataPoint based on response
                DataPoint dpToAdd = new DataPoint(
                    responseData[1], 
                    responseData[2], 
                    responseData[3], 
                   (responseData[4] > 0)
                   );
                vehicleController.addDataPointToStorage(dpToAdd);
                break;
            
            case 1:
                println("vehicle got new coords");
                vehicleController.setTargetInStorage(new int[]{responseData[1], responseData[2]});
                vehicleReadyForCommand = false;
            break;
            
            case 2:
                println("vehicle stopped");
                vehicleControllerActive = false;
                vehicleReadyForCommand = true;
                break;
            
            default:
            println("Wrong response");
            return;	   
        }
    }
    
    
    private void requestStatus() {
        //Send a reqest for status to vehicle
        println("requestStatus");
        vehicleController.requestArduinoStatus();
        lastStatusTime = millis(); //reset timer
    }
    
    
    void startVehicle() {
        //Begin operation
        if (vehicleControllerActive) return;
        generateAndDriveToTarget();
        vehicleControllerActive = true;
        vehicleReadyForCommand = false;
        lastStatusTime = millis();
    }
    
    
    void stopVehicle() {
        //Stop operations
        if (!vehicleControllerActive) return;
        vehicleController.stopVehicle();
        vehicleReadyForCommand = false;
        lastStatusTime = millis();
    }
    
    
    void saveToTXT() {
        //Save alle datapoints to a txt-file called save.txt
        String[] dataToExport = vehicleController.exportDataPoints();
        saveStrings("save.txt", dataToExport);
    }
    
    
    void importFromTXT() {
        //Import datapoints from a txt-file
        String[] importedData = loadStrings("save.txt");
        
        //Parse data (one point pr. line) and instaziate dataPointClass
        for (String dataString : importedData) {
            String[] dataStringSplit = split(dataString, ';');
            DataPoint importedDP = new DataPoint(
                int(dataStringSplit[0]),
                int(dataStringSplit[1]),
                int(dataStringSplit[2]),
                ((int(dataStringSplit[3]) > 0))
            );
                        
            
            vehicleController.addDataPointToStorage(importedDP); //Add dataPoint to storage

            //If current dataPoint has an obsticale, calculate walls
            if (((int(dataStringSplit[3]) > 0))) {
                ArrayList<WallSegment> newWalls = vehicleController.generateWallSegments();
                vehicleController.addWallSegmentsToStorage(newWalls);
            }
            
        }
    }
    
    
    void handleCommand(String printText) {
        //Handle manually written commands
        println(printText);
    }
    
}