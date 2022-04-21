//Colors used in program
HashMap<String, Integer> Colors = new HashMap<String, Integer>() {{
    put("primary", color(204, 153, 70));
    put("primaryDark", color(204, 153, 0));
    put("secondary", color(204, 53, 00));
    put("clearPoint", color(10, 128, 10));
    put("obstaclePoint", color(10, 10, 10));
    
}};


//Types of data that can be requested through requestData()
HashMap<String, Integer> Requests = new HashMap<String, Integer>() {{
    put("allStorage", 0);
    put("lastPosition", 1);
    put("lastObstacle", 2);
    put("lastObstacleAngle", 3);
    put("neighborKeys", 4); //must use extra data 'key;radius' (e.g. 12,34;2)
    put("dataPointList", 5); //must use extra data 'key' (e.g. 12,34)
    put("dataPointListMap", 6);
}};


//Names on buttons ID and method names for actions when clicked
HashMap<Integer, String> ButtonActions = new HashMap<Integer, String>() {{
    put(0, "startVehicle");
    put(1, "stopVehicle");
}};


//Names of FieldID and names for actions / methods when enter is pressed
HashMap<Integer, String> FieldActions = new HashMap<Integer, String>() {{
    put(0, "testHandleButton");
    put(1, "testHandleButton");
}};


//List with all interactive UIElements
ArrayList<Button> ButtonList = new ArrayList<Button>();
ArrayList<TextField> FieldList = new ArrayList<TextField>();


//Testelements used to test varius functions
Button TestButton0 = new Button(0);
Button TestButton1 = new Button(1);
TextField TestField = new TextField(0);


//Add all buttons to a single list and config
void setupInteractiveElements() {
    //Buttons
    TestButton0.setNewText("Start");
    TestButton1.setNewText("Stop");
    ButtonList.add(TestButton0);
    ButtonList.add(TestButton1);

    FieldList.add(TestField);
}

