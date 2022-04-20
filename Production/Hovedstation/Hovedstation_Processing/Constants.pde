int w, h; //Screen width and height


//Colors used in program
HashMap<String, Integer> Colors = new HashMap<String, Integer>() {{
    put("key1", color(204, 153, 0));
    put("key2", color(204, 153, 50));
    put("key3", color(204, 53, 00));
}};


//Types of data that can be requested through requestData()
HashMap<String, Integer> Requests = new HashMap<String, Integer>() {{
    put("allStorage", 0);
    put("lastPosition", 1);
    put("lastObstacle", 2);
    put("lastObstacleAngle", 3);
}};


//Names on buttons ID and method names for actions when clicked
HashMap<Integer, String> ButtonActions = new HashMap<Integer, String>() {{
    put(0, "startVehicle");
    put(1, "stopVehicle");
}};


//List with all buttons
ArrayList<Button> ButtonList = new ArrayList<Button>();

//Testbuttons used to test varius functions
Button TestButton0 = new Button(0);
Button TestButton1 = new Button(1);

//Add all buttons to a single list and config
void setupButtons() {
    TestButton0.setNewText("Start");
    TestButton1.setNewText("Stop");
    ButtonList.add(TestButton0);
    ButtonList.add(TestButton1);
}

