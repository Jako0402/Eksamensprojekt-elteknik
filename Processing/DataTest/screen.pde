void keyPressed() {
    if (key == ENTER) {
        keyDoStuff();
        text = "";
    } else if (key == CODED) {
        if (keyCode  == CONTROL) obstacle = !obstacle;
    } else if (key == BACKSPACE) {
        text = text.substring(0, text.length() - 1);
    } else{
        text += key;
    }
}


void keyDoStuff() {
    String toParse = text.toLowerCase();
    println(toParse);
    if (match(toParse, "clear") != null) {
        println("clear");
        dataMap = new HashMap<String, ArrayList<DataPoint>>();
    }
}


void mouseWheel(MouseEvent event) {
    //https://processing.org/reference/mouseWheel_.html
    int e = event.getCount();
    //1 = mod bruger
    //-1 = væk fra bruger
    //println(e);
    if (e > 0) {
        rotation += 10;
        if (rotation > 350) rotation = 0;
    } else{
        rotation -= 10;
        if (rotation < 0) rotation = 350;
    }
}


void mousePressed() {
    //print("MOUSE");
    addDataPoint(mouseX / 10, mouseY / 10, rotation);
}