import processing.serial.*;


View screen = new View(0,0,1080,720);


void setup() {
    surface.setResizable(true);
    surface.setTitle("Eksamen i El-teknik 2022");
    size(1080, 720);
    textSize(40);
    
    
    
    
    screen.addChildrenToList(new UIElement[] {
        new Row().addChildrenToList(new UIElement[] {
            new Column()
        })
    });
}


void draw() {
    background(100); 
    screen.display();
    
    screen.setComponentSize(width, height);
    screen.rescaleChildren();
}

