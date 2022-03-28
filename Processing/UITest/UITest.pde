Row row = new Row(0, 0, 0, 0);

void setup() {
    size(1080, 720);
    textSize(40);
    
    TestBox tb = new TestBox(100, 100, 200, 250);
    row.addElementToList(tb);
    
}

void draw() {
    background(100); 
    row.displayElements();
    
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
    
    void displayElements() {
        for (UIElement element : children) {
            element.displayElements();
        }
    }
    
    void addElementToList(UIElement elementToAdd) {
        children.add(elementToAdd);
    }
}


class Row extends UIElement {
    Row(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
}


class Column extends UIElement {
    Column(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
}


class TestBox extends UIElement {
    TestBox(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
    }
    
    @Override
    void displayElements() {
        rect(origoX, origoY, componentWidth, componentHeight);
    }
}