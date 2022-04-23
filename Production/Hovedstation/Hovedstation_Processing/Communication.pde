class ComDevice {
    Serial comPort; //Connected arduino
    String lastPortRead; //Last serial.read()
    int[] expectedDataLengthArray = {4, 2, 0}; //Response length from vehicle
    int[] responseBuffer; 
    int maxTimeout = 1000; //ms
    int commandSendTime; //millis()-reading at Serial.write()
    int responseStatus = 0;
    boolean newData = false; //True = need to read checksum
    
    ComDevice(Serial comPort) {
        this.comPort = comPort;
        comPort.bufferUntil('!');
    }
    
    
    public void update() {
        //Called every frame from void draw()
        //print(responseStatus + " ");
        
        //Checks for timeout and incomming response
        if (responseStatus == 1) { //Waiting for response
            if ((millis() - commandSendTime) > maxTimeout) { //Check timeout
                println("Timeout");
                responseStatus = 4; //Timeout
            } else {
                if (checkForEndCS()) responseStatus = 2; //If '!' is read, read CS (next char) and set status = 2
            }
        }
        
        //Parse response
        if (responseStatus == 2) { 
            println("Response: " + lastPortRead); //Debug: Print response to console
            
            if (validateData(lastPortRead) != 0) {  //Check package integrity
                println("Error: Bad read"); 
                responseStatus = 5; //Bad package
                return;
            } 
            
            responseBuffer = splitDataToArray(lastPortRead); //Split to int[]
            if (!checkResponseMatch(responseBuffer)) { //(not implementet yew)
                println("Mismatch between command and repsonse");
                responseStatus = 6;
                return;
            }

            responseStatus = 3; //Data ready to read
        }    
    }
    
    
    public void serialEvent() {
        //Called from void serialEvent()
        if (responseStatus == 1) { //Check if waiting for respones
            lastPortRead = comPort.readString();
            newData = true; //We need to read the checksum
            //println("lastPortRead: " + lastPortRead);
        } else {
            comPort.clear(); //Clear buffer if not waiting
        }
    }
    
    
    public boolean sendCommand(int id, int[] contet) {
        //Checks and sends a command to Arduino
        if (!checkParameterLength(id, contet)) return false; //Wrong parameter length
        
        String commandToSend = generateCommand(id, contet); 
        int checksumToSend = int(sumByteFromString(commandToSend)); //Loop through all chars and sum to a checksum
        
        print("commandToSend: " + commandToSend); //DEBUG: print what is send to colsole
        println(char(checksumToSend));

        if (!pushDataToSerial(commandToSend, checksumToSend)) return false; //Error sending (not implemented yew)
        
        return true; //Send complete
    }
    
    
    public int getReponseStatus() {
        //0 = Not expecting a response from vehicle
        //1 = Waiting for response
        //2 = Wait - Parsing response
        //3 = Reponse ready to read
        //4 = Error: Timeout
        //5 = Error: Bad read / package
        //6 = Eroor: Mismatch between command and repsonse (not implementet yew)
        return responseStatus;
    }


    public void setReponseStatus(int responseStatus) {
        this.responseStatus = responseStatus;
    }

    
    public int[] getReponseData() {
        if (responseStatus != 3) println("Warning: getReponseData returning bad data");
        return responseBuffer;
    }
    
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    private int validateData(String dataToValidate) {
        //0 = Valid package
        //1 = Wrong checksum
        //2 = Fist char is not ´?´ 
        //3 = CommandID not number
        //4 = Wrong command
        //5 = ';' not found
        //6 = '!' not found
        
        //Checks if CS is valid
        if (!validateChecksum(dataToValidate)) return 1;
        
        //Steps through data one char at a time to validate data
        int index = 0; //Current char to validate
        if (dataToValidate.charAt(index) != '?') return 2; //First char must be '?'
        index++;
        
        if (dataToValidate.charAt(index) == '-') index++; //Skip leeding '-'
        String commandIDStr = str(dataToValidate.charAt(index)); //First character is commadID
        if (!isInt(commandIDStr)) return 3; //Must be a number
        int commandID = int(commandIDStr);
        
        if (commandID >= expectedDataLengthArray.length) return 4; //Check if command exists
        int expectedDataLength = expectedDataLengthArray[commandID];
        
        //Check for ';' and numbers n times according to 'expectedDataLengthArray'
        for (int i = 0; i < expectedDataLength; i++) {
            index++;
            if (dataToValidate.charAt(index) != ';') return 5; //Must have a ';' before numbers
            index++;
            if (dataToValidate.charAt(index) == '-') index++; //Skip leeding '-'
            //Loops through all numbers
            while(true) {
                String currentIntStr = str(dataToValidate.charAt(index));
                if (isInt(currentIntStr)) {
                    index++;
                } else{
                    index--;
                    break;
                }
            }
        }
        
        //Check for end character
        index++;
        if (dataToValidate.charAt(index) != '!') return 6; //End character must be '!'
        
        //If no error has been found. The package is valid
        return 0;
    }
    
    
    private boolean validateChecksum(String dataToValidate) {
        //Takes the last character of a string and compares it to the rest of the string (summed as bytes na comverted to char). 
        //true = matching checksum
        String checksumString = dataToValidate.substring(0, dataToValidate.length() - 1);
        byte expectedCS = sumByteFromString(checksumString);
        
        byte receivedCS = byte(dataToValidate.charAt(dataToValidate.length() - 1));
        
        if (receivedCS != expectedCS) {
            //println("Error: Wrong CS");
            println("expectedCS: " + char(expectedCS) + " (as int: " + expectedCS + ")");
            println("receivedCS: " + char(receivedCS) + " (as int: " + receivedCS + ")");
            return false;
        }
        return true;
    }
    
    
    private byte sumByteFromString(String stringToSum) {
        //Takes a string and ruturns the byte corresponding to the sum of bytes
        byte totalSum = 0;
        for (char toAdd : stringToSum.toCharArray()) {
            //println(toAdd);
            totalSum += int(toAdd);
        }
        return totalSum;
    }
    
    
    private boolean isInt(String testStr) {
        //Takes a string and returns true if it is a number
        if (testStr == null) { //Empty string
            return false; //not int
        }
        
        try {
            int testInt = Integer.parseInt(testStr);
        } catch(NumberFormatException e) {
            return false; //not int
        }
        
        return true; //it is an int
    }
    
    
    private boolean checkParameterLength(int id, int[] contet) {
        //Checks parameter-id length match. Returns true if correct parameters is met
        
        //Checks for correct number of parameters
        switch(id) {
            case 0:
                if (contet.length != 0) return false;
                break;
            
            case 1:
                if (contet.length != 2) return false;
                break;
            
            case 2:
                if (contet.length != 0) return false;
                break;
            
            default:
            return false;
        }
        return true;    
    }
    
    
    private String generateCommand(int id, int[] contet) {
        //Generetes and returnscommand (no checksum)
        String commandToSend = "?" + str(id) + ";"; //Add start to command

        //All commands follow structure 'int;' repeated 
        for (int i : contet) {
            commandToSend += str(i);
            commandToSend += ';';
        }
        commandToSend = commandToSend.substring(0, commandToSend.length() - 1); //remove last ';'
        commandToSend += "!"; //Add ending to command
        
        
        //println("commandToSend: " + commandToSend);
        //println("newChecksum: " + newChecksum);
        return commandToSend;
    }
    
    
    private boolean pushDataToSerial(String commandToSend, int checksumToSend) {
        //Sends data to serial device. TODO: add check here later
        comPort.write(commandToSend);
        comPort.write(checksumToSend);
        commandSendTime = millis(); //Start timeout timer
        responseStatus = 1; //We are now waiting for respons
        return true;
    }
    
    
    private int[] splitDataToArray(String fullPackage) {
        //Takes the full package and splits to array of integers
        String trimmedPackage = fullPackage.substring(1, fullPackage.length() - 2); //Removes begin, end, and checksum
        int[] splitData = int(split(trimmedPackage, ';'));
        return splitData;
    }
    
    
    private boolean checkForEndCS() {
        //Reads one char (CS) from Serial and appends it to 'lastPortRead'. Returns true if CS read
        if (newData) {
            lastPortRead += comPort.readChar();
            newData = false; //We have now read CS
            comPort.clear();
            return true;
        }
        return false;
    }


    private boolean checkResponseMatch(int[] receivedResponse) {
        //Check is the resonse matches the command send (not implementet yew)
        return true;
    }
}