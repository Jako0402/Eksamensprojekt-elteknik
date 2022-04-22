//Layers used for alle UI-elements (higher number = in front)
//0 = Dataview (it stretches over component size. Must be furthest behind)
//1 = other UIElements
//2 = right-click menu (not programmed yew)
PGraphics[] layers = new PGraphics[2];

//Colors used in program
HashMap<String, Integer> Colors = new HashMap<String, Integer>() {{
    put("primary", color(204, 153, 70));
    put("primaryDark", color(204, 153, 0));
    put("secondary", color(204, 53, 00));
    put("clearPoint", color(10, 128, 10));
    put("obstaclePoint", color(10, 10, 10));
    put("targetPoint", color(255, 10, 10));
    put("positionPoint", color(10, 10, 255));
    put("outline", color(0, 0, 0));
    put("gridLine", color(130, 130, 130));
    put("walls", color(35, 35, 35));
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
    put(2, "saveToTXT");
    put(3, "importFromTXT");
}};


//Names of FieldID and names for actions / methods when enter is pressed
HashMap<Integer, String> FieldActions = new HashMap<Integer, String>() {{
    put(0, "handleCommand");
}};


//List with all interactive UIElements
ArrayList<Button> ButtonList = new ArrayList<Button>();
ArrayList<TextField> FieldList = new ArrayList<TextField>();


//Testelements used to test varius functions
Button StartButton = new Button(0);
Button StopButton = new Button(1);
Button SaveButton = new Button(2);
Button RestoreButton = new Button(3);
TextField TestField = new TextField(0);


//Add all buttons to a single list and config
void setupInteractiveElements() {
    //Buttons
    StartButton.setNewText("Start");
    StopButton.setNewText("Stop");
    SaveButton.setNewText("Save");
    RestoreButton.setNewText("Restore");

    ButtonList.add(StartButton);
    ButtonList.add(StopButton);
    ButtonList.add(SaveButton);
    ButtonList.add(RestoreButton);

    FieldList.add(TestField);
}

