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
    
    
    void display() {
        for (UIElement element : children) {
            element.display();
        }
    }
    
    
    UIElement addChildrenToList(UIElement[] elementsToAdd) {
        for (UIElement childToAdd : elementsToAdd) {
            children.add(childToAdd);
        }
        return this;
    }
    
    
    void setOrigo(int newOrigoX, int newOrigoY) {
        origoX = newOrigoX;
        origoY = newOrigoY;
    }
    
    
    void setComponentSize(int newComponentWidth, int newcCmponentWidth) {
        componentWidth = newComponentWidth;
        componentHeight = newcCmponentWidth;
    }
    
    
    UIElement getChild(int index) {
        if (index >= children.size()) {
            println("ERROR: getChild is out of index");
            return new UIElement(0, 0, 0, 0);
        }
        return children.get(index);
    }
    
    
    void rescaleChildren() {
        for (UIElement element : children) {
            element.rescaleChildren();
        }
    }
    
    
    int getComponentWidth() {
        return componentWidth;
    }
    
    
    int getComponentHeight() {
        return componentHeight;
    }
}


class View extends UIElement {
    View(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
    
    
    @Override
    void rescaleChildren() {
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
    UIElement addChildrenToList(UIElement[] elementsToAdd) {
        super.addChildrenToList(elementsToAdd);
        for (int i = 0; i < children.size(); i++) {
            this.axisLengths[i] = 1;     
        }
        return this;
    }
    
    
    int getTotalAxisLength() {
        int tempLength = 0;
        for (int i : axisLengths) {
            tempLength += i;
        }
        return tempLength;
    }
    
    
    @Override
    void rescaleChildren() {
        super.rescaleChildren();
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
    void rescaleChildren() {
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
    void rescaleChildren() {
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
    void display() {
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
    
    
    void setTextAlign(char align) {
        if (align == 'L' || align == 'C' ||  align == 'R') {
            textAlign = align; 
        } else{
            println("ERROR: Not supported align. Use 'L', 'C' og 'R'");
        }
    }
    
    
    void setNewText(String newText) {
        text = newText;
    }
}


class Button extends Text {
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
        if (mouseX >= origoX && mouseX <= origoX + componentWidth && 
            mouseY >= origoY && mouseY <= origoY + componentHeight) {
            return true;
        } else {
            return false;
        }
    }
}


class TestBox extends Text {
    TestBox(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
    
    
    @Override
    void display() {
        fill(150);
        rect(origoX, origoY, componentWidth, componentHeight);
        super.display();
    }
}
