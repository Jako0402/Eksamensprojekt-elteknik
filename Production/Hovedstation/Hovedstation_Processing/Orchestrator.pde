class Orchestrator {
    VehicleController vehicleController;
    Storage storage;
    int timeoutCounter = 0;
    boolean vehicleControllerActive = false;
    boolean vehicleReadyForCommand = true;
    
    
    Orchestrator(VehicleController vehicleController) {
        this.vehicleController = vehicleController;
        this.storage = vehicleController.getStorage();
    }
    
    
    public void update() {
        //called every frame
        vehicleController.update();
        if (vehicleControllerActive) operateVehicle();
    }
    
    public void handleButton(int ButtonID) {
        try {
            this.getClass().getMethod(ButtonActions.get(ButtonID)).invoke(this);
        } catch (Exception e) {
            println("Error method name: " + e);
        }
    }
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    private void operateVehicle() {
        if (timeoutCounter > 10) {
            println("TOO MANY TIMEOUTS...CODE A FIX HERE");
        }
        
        int status = vehicleController.getArduinoReponseStatus();
        switch(status) {
            
            case 3:
                //Good response
                handleGoodResponse();
                timeoutCounter = 0;
                break;
            
            case 4:
            case 5:
            case 6:
                //Timeout
                vehicleController.resendLastCommand();
                vehicleReadyForCommand = false;
                timeoutCounter++;
                break;

        }
        
        
        if (vehicleReadyForCommand) {
            generateAndDriveToTarget();
        }
    }
    
    
    private void generateAndDriveToTarget() {
        vehicleController.driveToTarget(vehicleController.generateNewTarget());
        vehicleReadyForCommand = false;
    }
    
    
    private void handleGoodResponse() {
        //Ready resonse
        int[] responseData = vehicleController.getArduinoReponseData();
        vehicleController.setArduinoReponseStatus(0); //We have read response; we are no longer expecting a response
        
        switch(responseData[0]) {
            case 0:
                println("vehicle status update");
                vehicleReadyForCommand = !(responseData[3] == 0);
                break;
            
            case 1:
                println("vehicle got new coords");
                storage.setCurrentTarget(new int[]{responseData[1], responseData[2]});
            vehicleReadyForCommand = false;
            break;
            
            case 2:
                println("vehicle stopped");
                vehicleControllerActive = false;
                vehicleReadyForCommand = true;
                break;
            
            default:
            println("Wrong response");
            break;	
            
        }
    }
    
    
    void startVehicle() {
        if (vehicleControllerActive) return;
        generateAndDriveToTarget();
        vehicleControllerActive = true;
        vehicleReadyForCommand = false;
    }
    
    
    void stopVehicle() {
        if (!vehicleControllerActive) return;
        vehicleController.stopVehicle();
        vehicleControllerActive = false;
        vehicleReadyForCommand = true;
    }
}