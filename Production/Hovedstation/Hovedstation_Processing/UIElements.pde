class UIElement {
    int origoX, origoY, componentWidth, componentHeight; 
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
        for (UIElement element : children) {
            element.display();
        }
    }
    
    
    public UIElement addChildrenToList(UIElement[] elementsToAdd) {
        for (UIElement childToAdd : elementsToAdd) {
            children.add(childToAdd);
        }
        return this;
    }
    
    
    public void setOrigo(int newOrigoX, int newOrigoY) {
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
    int[] axisLengths;
    int totalAxisLength;
    
    
    Axis(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
        axisLengths = new int[12];
    }
    
    
    Axis() {
        super();
        axisLengths = new int[12];
    }
    
    
    @Override
    public Axis addChildrenToList(UIElement[] elementsToAdd) {
        super.addChildrenToList(elementsToAdd);
        for (int i = 0; i < children.size(); i++) {
            this.axisLengths[i] = 1;     
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
    String text = "Test";
    char textAlign = 'C';
    
    
    Text(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
    
    
    Text() {
        super();
    }
    
    
    @Override
    public void display() {
        switch(textAlign) {
            case 'L':
                textAlign(LEFT);
                break;
            case 'C':
                textAlign(CENTER);
                break;
            case 'R':
                textAlign(RIGHT);
                break;
        }
        
        fill(0);
        text(text, origoX, origoY, componentWidth, componentHeight);
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
    int buttonID;
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
        
        if (mouseHover) {
            fill(Colors.get("key2"));
        } else {
            isClicked = false;
            fill(Colors.get("key1"));
        }
        if (isClicked) fill(Colors.get("key3"));
        
        rect(origoX, origoY, componentWidth, componentHeight);
        super.display();
    }
    
    
    public boolean getButtonStatus() {
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
    int textFieldID;
    boolean readyToActivate = false;
    boolean fieldActive = false;
    
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
        fill(150);
        if (fieldActive) fill(250);
        
        rect(origoX, origoY, componentWidth, componentHeight);
        super.display();       
    }
    
    
    public void mousePressed() {
        //Called when mousePressed
        if (checkMouseHover()) {
            readyToActivate = true;
        }
    }
    
    
    public void mouseReleased() {
        //Called when mouseReleased
        if (readyToActivate && checkMouseHover()) {
            fieldActive = true;

        } else{
            fieldActive = false;
            readyToActivate = false;
        }
    }
    
    
    public void keyPressed() {
        //Called when key is pressed
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
        rect(origoX, origoY, componentWidth, componentHeight);
        super.display();
    }
}
