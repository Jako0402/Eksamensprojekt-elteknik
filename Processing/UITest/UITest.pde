Column col1 = new Column(0,0,180,720);

void setup() {
    surface.setResizable(true);
    size(1080, 720);
    textSize(40);
    
    TestBox newTestBox1 = new TestBox(0, 0, 0, 0);
    TestBox newTestBox2 = new TestBox(0, 0, 0, 0);
    TestBox newTestBox3 = new TestBox(0, 0, 0, 0);
    TestBox newTestBox4 = new TestBox(0, 0, 0, 0);
    TestBox newTestBox5 = new TestBox(0, 0, 0, 0);

    Row row1 = new Row(0, 0, 1080, 720);
    Row row2 = new Row(0, 0, 1080, 720);
    
    row1.addChildToList(newTestBox1);
    row1.addChildToList(newTestBox2);
    row1.addChildToList(newTestBox3);
    row2.addChildToList(newTestBox4);
    row2.addChildToList(newTestBox5);
    
    newTestBox1.setNewText("Test1");
    newTestBox2.setNewText("Test2");
    newTestBox3.setNewText("Test3");
    newTestBox4.setNewText("Test4");
    newTestBox5.setNewText("Test5");
    
    row1.colWidth[0] = 1;
    row1.colWidth[1] = 2;
    row1.colWidth[2] = 4;
    
    row2.colWidth[0] = 3;
    row2.colWidth[1] = 2;
    
    col1.addChildToList(row1);
    col1.addChildToList(row2);
}

void draw() {
    background(100); 
    col1.display();
    
    col1.setComponentSize(width, height);
    col1.rescaleChildren();
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
    
    void addChildToList(UIElement elementToAdd) {
        children.add(elementToAdd);
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
        this.colWidth[children.size() - 1] = 1;     
    }
    
    @Override
    void rescaleChildren() {
        totalColWidth = 0;
        for (int i : colWidth) {
            totalColWidth += i;
        }
        
        int tempOrigoX = 0;
        for (int i = 0; i < children.size(); i++) {
            int newComponentWidth = int(float(colWidth[i]) / float(totalColWidth) * this.getComponentWidth());
            int newComponentHeight = this.getComponentHeight();
            this.getChild(i).setComponentSize(newComponentWidth, newComponentHeight);
            
            
            this.getChild(i).setOrigo(tempOrigoX, origoY);
            tempOrigoX += this.getChild(i).getComponentWidth();
        }
        super.rescaleChildren();
    }
    
}


class Column extends UIElement {
    int[] rowWidth;
    int totalRowWidth = 0;
    Column(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
        rowWidth = new int[12]; //One Column cannot have more than 12 elements. Might need rework
    }
    
    @Override
    void addChildToList(UIElement elementToAdd) {
        super.addChildToList(elementToAdd);
        this.rowWidth[children.size() - 1] = 1;     
    }
    
    @Override
    void rescaleChildren() {
        totalRowWidth = 0;
        for (int i : rowWidth) {
            totalRowWidth += i;
        }
        
        int tempOrigoY = 0;
        for (int i = 0; i < children.size(); i++) {
            int newComponentWidth = this.getComponentWidth();
            int newComponentHeight = int(float(rowWidth[i]) / float(totalRowWidth) * this.getComponentHeight());
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
