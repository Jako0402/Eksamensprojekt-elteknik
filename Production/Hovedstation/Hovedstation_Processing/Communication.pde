class ComDevice {
    Serial comPort;
    String lastPortRead;
    int[] expectedDataLengthArray = {4, 2, 0};
    boolean newData = false;
    
    ComDevice(Serial comPort) {
        this.comPort = comPort;
        comPort.bufferUntil('!');
    }
    
    
    void update() {
        //Is called every frame from void draw()
        
        if (newData) {
            lastPortRead += comPort.readChar();
            newData = false;
            comPort.clear();
            println("validateData: " + validateData(lastPortRead));
            println("lastPortRead: " + lastPortRead);
        }
        
    }
    
    
    void serialEvent() {
        lastPortRead = comPort.readString();
        newData = true;
        //println("lastPortRead: " + lastPortRead);
    }
    
    
    int validateData(String dataToValidate) {
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
    
    
    boolean validateChecksum(String dataToValidate) {
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
    
    
    byte sumByteFromString(String stringToSum) {
        //Takes a string and ruturns the byte corresponding to the sum of bytes
        byte totalSum = 0;
        for (char toAdd : stringToSum.toCharArray()) {
            //println(toAdd);
            totalSum += int(toAdd);
        }
        return totalSum;
    }
    
    
    boolean isInt(String testStr) {
        //Takes a string and returns true if it is a number
        if (testStr == null) { //Empty string
            return false;
        }
        
        try {
            int testInt = Integer.parseInt(testStr);
        } catch(NumberFormatException e) {
            return false;
        }
        
        return true;
    }
    
    
    boolean sendCommand(int id, int[] contet) {
        //Sends a command to vehicle. Returns true if correct parameters is met
        
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
        
        //Add ending to command
        String commandToSend = "?" + str(id) + ";";
        for (int i : contet) {
            commandToSend += str(i);
            commandToSend += ';';
        }
        commandToSend = commandToSend.substring(0, commandToSend.length() - 1); //remove last ';'
        commandToSend += "!";
        
        int newChecksum = int(sumByteFromString(commandToSend));
        //println("commandToSend: " + commandToSend);
        //println("newChecksum: " + newChecksum);

        comPort.write(commandToSend);
        comPort.write(newChecksum);
        return true;
    }
}