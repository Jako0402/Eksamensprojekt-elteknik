class Dataviewer extends UIElement {
    Storage storage;
    int[] viewX = { - 100, 100};
    int[] viewY = { - 100, 100};
    int cellResolution; //Must match Storage object
    
    
    Dataviewer(int origoX, int origoY, int componentWidth, int componentHeight, Storage storage) {
        super(origoX, origoY, componentWidth, componentHeight);
        this.storage = storage;
        this.cellResolution = storage.getCellResolution();
    }
    
    
    Dataviewer(Storage storage) {
        super();
        this.storage = storage;
        this.cellResolution = storage.getCellResolution();
    }
    
    
    @Override
    public void display() {
        fill(150);
        rect(origoX, origoY, componentWidth, componentHeight);
        calculateKeyList(viewX, viewY, cellResolution);
    }
    
    
    public int[] getViewX() {
        return viewX;
    }
    
    
    public int[] getViewY() {
        return viewY;
    }
    
    
    public void setViewX(int[] viewX) {
        this.viewX = viewX;
    }
    
    
    public void setViewY(int[] viewY) {
        this.viewY = viewY;
    }
    
    
    //Methods below this line are NOT supposed to be invoked from outside class//
    //-------------------------------------------------------------------------//
    private String[] calculateKeyList(int[] xRange, int[] yRange, int cellResolution) {
        //Takes 4 view-parameters and return a string with keys
        String[] foundKeys = {};

        if (xRange.length != 2 || yRange.length != 2) {
            println("Error: Wrong xRang or yRange length. Returning null");
            return null;
        }
        
        //Find all end keys
        int xMin = xRange[0] / 10 - 1;
        int xMax = xRange[1] / 10 + 1;
        int yMin= yRange[0] / 10 - 1;
        int yMax = yRange[1] / 10 + 1;
        //println("Keys: " + xMin + " " + xMax + " " + yMin + " " + yMax);

        //Loop and append keys
        for (int tempXKey = xMin; tempXKey <= xMax; tempXKey++) {
            for (int tempYKey = yMin; tempYKey <= yMax; tempYKey++) {
                foundKeys = append(foundKeys, str(tempXKey) + "," + str(tempYKey));
            }
        }

        return foundKeys;
    }

    
}