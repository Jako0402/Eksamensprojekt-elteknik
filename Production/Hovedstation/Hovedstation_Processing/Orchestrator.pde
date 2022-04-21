class Orchestrator {
    VehicleController vehicleController;
    int timeoutCounter = 0;
    int statusFrequency = 1200; //ms must be larger than timeout
    int lastStatusTime; //ms
    boolean vehicleControllerActive = false;
    boolean vehicleReadyForCommand = true;
    
    
    Orchestrator(VehicleController vehicleController) {
        this.vehicleController = vehicleController;
    }
    
    
    public void update() {
        //called every frame
        vehicleController.update();
        if (vehicleControllerActive) operateVehicle();
    }
    
    public void handleButton(int ButtonID) {
        try {
            this.getClass().getMethod(ButtonActions.get(ButtonID)).invoke(this);
        } catch(Exception e) {
            println("Error button method name: " + e);
        }
    }
    
    
    public void handleField(int FieldID, String fieldText) {
        try {
            this.getClass().getMethod(FieldActions.get(FieldID), String.class).invoke(this, fieldText);
        } catch(Exception e) {
            println("Error field method name: " + e);
        }
    }
    
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    private void operateVehicle() {
        int status = vehicleController.getArduinoReponseStatus();


        if ((millis() - lastStatusTime) > statusFrequency) {
            requestStatus();
        }


        if (timeoutCounter > 10) {
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
                //Timeout
                vehicleController.resendLastCommand();
                lastStatusTime = millis();
                vehicleReadyForCommand = false;
                timeoutCounter++;
                break;
            
        }
        
        
        if (vehicleReadyForCommand && vehicleControllerActive) {
            generateAndDriveToTarget();
        }
    }
    
    
    private void generateAndDriveToTarget() {
        vehicleController.driveToTarget(vehicleController.generateNewTarget());
        lastStatusTime = millis(); //reset counter for status update
        ArrayList<WallSegment> newWalls= vehicleController.generateWallSegments();
        vehicleController.addWallSegmentsToStorage(newWalls);
        vehicleReadyForCommand = false;
    }
    
    
    private void handleGoodResponse() {
        //Ready resonse
        int[] responseData = vehicleController.getArduinoReponseData();
        vehicleController.setArduinoReponseStatus(0); //We have read response; we are no longer expecting a response
        
        switch(responseData[0]) {
            case 0:
                println("vehicle status update");
                vehicleReadyForCommand = !(responseData[4] == 0);
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
        println("requestStatus");
        vehicleController.requestArduinoStatus();
        lastStatusTime = millis();
    }
    
    
    void startVehicle() {
        if (vehicleControllerActive) return;
        generateAndDriveToTarget();
        vehicleControllerActive = true;
        vehicleReadyForCommand = false;
        lastStatusTime = millis();
    }
    
    
    void stopVehicle() {
        if (!vehicleControllerActive) return;
        vehicleController.stopVehicle();
        vehicleReadyForCommand = false;
        lastStatusTime = millis();
    }
    
    
    void testHandleButton(String printText) {
        println(printText);
    }

}