class UIElement {
    //Parrentclass. Alle things drawn on scrren must exten this
    int origoX, origoY, componentWidth, componentHeight, layer; 
    ArrayList<UIElement> children;
    
    
    UIElement(int origoX, int origoY, int componentWidth, int componentHeight) {
        this.origoX = origoX;
        this.origoY = origoY;
        this.componentWidth = componentWidth;
        this.componentHeight = componentHeight;
        children = new ArrayList<UIElement>();
    }
    
    
    UIElement() {
        origoX = 0;
        origoY = 0;
        componentWidth = 0;
        componentHeight = 0;
        children = new ArrayList<UIElement>();
    }
    
    
    public void display() {
        //Displays alle children
        for (UIElement element : children) {
            element.display();
        }
    }
    
    
    public UIElement addChildrenToList(UIElement[] elementsToAdd) {
        //Add a child to list of children
        for (UIElement childToAdd : elementsToAdd) {
            children.add(childToAdd);
        }
        return this;
    }
    
    
    public void setOrigo(int newOrigoX, int newOrigoY) {
        //Origo = top left corner
        origoX = newOrigoX;
        origoY = newOrigoY;
    }
    
    
    public void setComponentSize(int newComponentWidth, int newcCmponentWidth) {
        componentWidth = newComponentWidth;
        componentHeight = newcCmponentWidth;
    }
    
    
    public UIElement getChild(int index) {
        if (index >= children.size()) {
            println("ERROR: getChild is out of index");
            return new UIElement(0, 0, 0, 0);
        }
        return children.get(index);
    }
    
    
    public void rescaleChildren() {
        for (UIElement element : children) {
            element.rescaleChildren();
        }
    }
    
    
    public int getComponentWidth() {
        return componentWidth;
    }
    
    
    public int getComponentHeight() {
        return componentHeight;
    }
}


class View extends UIElement {
    //Class that holds ONE other instance
    View(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
    
    
    @Override
    public void rescaleChildren() {
        UIElement child = this.getChild(0);
        child.setComponentSize(this.componentWidth, this.componentHeight);
        child.setOrigo(this.origoX, this.origoY);
        super.rescaleChildren();
    }
}


class Axis extends UIElement {
    //Holds children stacked (in a row or coloum)
    int[] axisLengths; //Each child size or length
    int totalAxisLength; //Total size or length
    
    
    Axis(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
        axisLengths = new int[12]; //Max 12 elements
    }
    
    
    Axis() {
        super();
        axisLengths = new int[12];
    }
    
    
    @Override
    public Axis addChildrenToList(UIElement[] elementsToAdd) {
        super.addChildrenToList(elementsToAdd);
        for (int i = 0; i < children.size(); i++) {
            this.axisLengths[i] = 1; //Child size is default 1    
        }
        return this;
    }
    
    
    @Override
    public void rescaleChildren() {
        super.rescaleChildren();
    }
   
    
    protected int getTotalAxisLength() {
        int tempLength = 0;
        for (int i : axisLengths) {
            tempLength += i;
        }
        return tempLength;
    }


    public Axis setAxisLengths(int[] axisLengths) {
        this.axisLengths = axisLengths;
        return this;
    }
}


class Row extends Axis {
    Row(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
    
    
    Row() {
        super();
    }
    
    
    @Override
    public void rescaleChildren() {
        totalAxisLength = getTotalAxisLength();
        
        int tempOrigoX = 0;
        for (int i = 0; i < children.size(); i++) {
            int newComponentWidth = int(float(axisLengths[i]) / float(totalAxisLength) * this.getComponentWidth());
            int newComponentHeight = this.getComponentHeight();
            this.getChild(i).setComponentSize(newComponentWidth, newComponentHeight);
            
            
            this.getChild(i).setOrigo(tempOrigoX, origoY);
            tempOrigoX += this.getChild(i).getComponentWidth();
        }
        super.rescaleChildren();
    }
}


class Column extends Axis {
    Column(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
    
    
    Column() {
        super();
    }
    
    
    @Override
    public void rescaleChildren() {
        totalAxisLength = getTotalAxisLength();
        
        int tempOrigoY = 0;
        for (int i = 0; i < children.size(); i++) {
            int newComponentWidth = this.getComponentWidth();
            int newComponentHeight = int(float(axisLengths[i]) / float(totalAxisLength) * this.getComponentHeight());
            this.getChild(i).setComponentSize(newComponentWidth, newComponentHeight);
            
            this.getChild(i).setOrigo(origoX, tempOrigoY);
            tempOrigoY += this.getChild(i).getComponentHeight();
        }
        super.rescaleChildren();
    }
}


class Text extends UIElement {
    //Writes text
    String text = "Test";
    char textAlign = 'C'; //C=Center, L=left, R=right
    
    
    Text(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
        layer = 1;
    }
    
    
    Text() {
        super();
        layer = 1;
    }
    
    
    @Override
    public void display() {
        //Change align
        switch(textAlign) {
            case 'L':
                layers[layer].textAlign(LEFT);
                break;
            case 'C':
                layers[layer].textAlign(CENTER);
                break;
            case 'R':
                layers[layer].textAlign(RIGHT);
                break;
        }
        
        //Draw text
        layers[layer].fill(0);
        layers[layer].textSize(40);
        layers[layer].text(text, origoX, origoY, componentWidth, componentHeight);
    }
    
    
    public void setTextAlign(char align) {
        if (align == 'L' || align == 'C' ||  align == 'R') {
            textAlign = align; 
        } else{
            println("ERROR: Not supported align. Use 'L', 'C' og 'R'");
        }
    }
    
    
    public void setNewText(String newText) {
        text = newText;
    }


    public String getText() {
        return text;
    }
}


class Button extends Text implements MouseHover{
    boolean isClicked = false;
    boolean mouseHover = false;
    int buttonID; //Used to inkove correct method by buttonhandler
    Button(int origoX, int origoY, int componentWidth, int componentHeight, int buttonID) {
        super(origoX, origoY, componentWidth, componentHeight);
        this.buttonID = buttonID;
    }
    
    
    Button(int buttonID) {
        super();
        this.buttonID = buttonID;
    }
    
    
    @Override
    public void display() {
        mouseHover = checkMouseHover();
        
        //Change color based on status
        if (mouseHover) {
            layers[1].fill(Colors.get("primaryDark"));
        } else {
            isClicked = false;
            layers[1].fill(Colors.get("primary"));
        }
        if (isClicked) layers[layer].fill(Colors.get("secondary"));

        //Draw button
        layers[layer].stroke(Colors.get("outline"));
        layers[layer].rect(origoX, origoY, componentWidth, componentHeight);
        super.display();
    }
    
    
    public boolean getButtonStatus() {
        //Get status. Change to false when read + true
        if (isClicked) {
            isClicked = false;
            return true;
        } else {
            return false;
        }
    }
    
    
    public boolean getButtonHover() {
        return mouseHover;
    }
    
    
    public void setIsClicked(boolean clickedValue) {
        isClicked = clickedValue;
    }
    
    
    public int getButtonID() {
        return buttonID;
    }
    
    
    private boolean checkMouseHover() {
        return MouseHover.checkMouseHover(origoX, origoY, componentWidth, componentHeight, mouseX, mouseY);
    }
}


class TextField extends Text implements MouseHover{
    int textFieldID; //Used to invoke correct method
    boolean readyToActivate = false; //clicked + mousehover
    boolean fieldActive = false; //true = write text here
    
    TextField(int origoX, int origoY, int componentWidth, int componentHeight, int textFieldID) {
        super(origoX, origoY, componentWidth, componentHeight);
        this.textFieldID = textFieldID;
    }
    
    
    TextField(int textFieldID) {
        super();
        this.textFieldID = textFieldID;
    }
    
    
    @Override
    public void display() {
        //Change color based on status
        layers[layer].fill(150);
        if (fieldActive) layers[layer].fill(250);
        
        layers[layer].rect(origoX, origoY, componentWidth, componentHeight);
        super.display();       
    }
    
    
    public void mousePressed() {
        //Called when mousePressed
        if (checkMouseHover()) { //If hover and mouse = readyToActivate
            readyToActivate = true;
        }
    }
    
    
    public void mouseReleased() {
        //Called when mouseReleased. Field is active when mouse is realased 
        if (readyToActivate && checkMouseHover()) {
            fieldActive = true;

        } else{
            fieldActive = false;
            readyToActivate = false;
        }
    }
    
    
    public void keyPressed() {
        //Called when key is pressed. Add text to field if active
        if (!fieldActive || key == CODED) return;
        if (key == ENTER) {
            fieldActive = false;
            readyToActivate = false;
            setNewText("");
        } else if (key == BACKSPACE) {
            if (text.length() < 1) return;
            text = text.substring(0, text.length() - 1);
        } else{
            text += key;
        }
    }
    

    public boolean getFieldActive() {
        return fieldActive;
    }


    public int getFieldID() {
        return textFieldID;
    }

    
    public boolean checkMouseHover() {
        return MouseHover.checkMouseHover(origoX, origoY, componentWidth, componentHeight, mouseX, mouseY);
    }
}


class TestBox extends Text {
    //Only used to test internal programming
    TestBox(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
    
    
    @Override
    public void display() {
        fill(150);
        layers[layer].rect(origoX, origoY, componentWidth, componentHeight);
        super.display();
    }
}
