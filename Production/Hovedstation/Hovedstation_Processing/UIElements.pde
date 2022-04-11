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

class Row extends UIElement {
    int[] colWidth;
    int totalColWidth = 0;
    Row(int origoX, int origoY, int componentWidth, int componentHeight) {
        super(origoX, origoY, componentWidth, componentHeight);
        colWidth = new int[12]; //One row cannot have more than 12 elements. Might need rework
    }

    Row() {
        super();
        colWidth = new int[12];
    }
    
    @Override
    UIElement addChildrenToList(UIElement[] elementsToAdd) {
        super.addChildrenToList(elementsToAdd);
        for (int i = 0; i < children.size(); i++) {
            this.colWidth[i] = 1;     
        }
        return this;
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

    Column() {
        super();
        rowWidth = new int[12];
    }
    
    @Override
    UIElement addChildrenToList(UIElement[] elementsToAdd) {
        super.addChildrenToList(elementsToAdd);
        for (int i = 0; i < children.size(); i++) {
            this.rowWidth[i] = 1;     
        }  
        return this;
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
