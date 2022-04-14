//Colors used in program
HashMap<String, Integer> Colors = new HashMap<String, Integer>() {{
    put("key1", color(204, 153, 0));
    put("key2", color(204, 153, 50));
    put("key3", color(204, 53, 00));
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

