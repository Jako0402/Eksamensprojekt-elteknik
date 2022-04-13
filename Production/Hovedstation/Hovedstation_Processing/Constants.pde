//Colors used in program
HashMap<String, Integer> Colors = new HashMap<String, Integer>() {{
    put("key1", color(204, 153, 0));
    put("key2", color(204, 153, 50));
    put("key3", color(204, 53, 00));
}};

//List with all buttons
ArrayList<Button> ButtonList = new ArrayList<Button>();

//Testbutton used to test varius functions
Button TestButton = new Button(0);

//Add all buttons to a single list and config
void setupButtons() {
    TestButton.setNewText("Start");
    ButtonList.add(TestButton);
}

