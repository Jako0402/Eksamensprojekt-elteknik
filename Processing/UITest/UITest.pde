Row row = new Row(0, 0, 0, 0);

void setup() {
    surface.setResizable(true);
    size(1080, 720);
    textSize(40);
    
    TestBox newTestBox = new TestBox(100, 100, 200, 250);
    row.addChildToList(newTestBox);
    
    
    newTestBox.setTextAlign('L');
    newTestBox.setNewText("Dette er en ny tekst");
    
}

void draw() {
    background(100); 
    row.display();
    
    int[] mouse = {mouseX, mouseY};
    row.getChild(0).setOrigo(mouse);
}

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
    
    void display() {
        for (UIElement element : children) {
            element.display();
        }
    }
    
    void addChildToList(UIElement elementToAdd) {
        children.add(elementToAdd);
    }
    
    void setOrigo(int[] newOrigo) {
        if (newOrigo.length != 2) println("ERROR: newOrigo must have 2 values");
        origoX = newOrigo[0];
        origoY = newOrigo[1];
    }
    
    void setComponentSize(int[] newSize) {
        if (newSize.length != 2) println("ERROR: newSize must have 2 values");
        componentWidth = newSize[0];
        componentHeight = newSize[1];
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
}


class Row extends UIElement {
    int[] colWidth;
    int totalColWidth = 0;
    Row(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
        colWidth = new int[12]; //One row cannot have more than 12 elements. Might need rework
    }
    
    @Override
    void addChildToList(UIElement elementToAdd) {
        super.addChildToList(elementToAdd);
        colWidth[children.size() - 1] = 1;     
    }
    
    @Override
    void rescaleChildren() {
        totalColWidth = 0;
        for (int i : colWidth) {
            totalColWidth += i;
        }
        
        for (UIElement element : children) {
            int origoX = 
            element.setOrigo();
            element.setComponentSize();
        }
        
        super.rescaleChildren();
    }
}


class Column extends UIElement {
    Column(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
}


class Text extends UIElement {
    String text = "Test";
    char textAlign = 'C';
    
    Text(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
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
