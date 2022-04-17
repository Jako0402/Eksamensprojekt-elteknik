class Dataviewer extends UIElement implements MouseHover {
    Storage storage;
    int[] viewX = { - 100, 100};
    int[] viewY = { - 100, 100};
    int[] viewOrigin;
    int[] lastMouseCoords;
    int cellResolution; //Must match Storage object
    boolean canDrag = false;
    boolean showCoords = false;
    
    
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


        String[] keys = calculateKeyList(viewX, viewY, cellResolution);
        ArrayList<ArrayList<DataPoint>> listList = getPointListList(keys);

        for (ArrayList<DataPoint> list : listList) {
            for (DataPoint dp : list) {
                fill(0);
                int[] coords = geCoordinatesToPixels(dp.getXpos(), dp.getYpos());
                circle(coords[0], coords[1], 10);
            }
        }
        
        //println(MouseHover.checkMouseHover(origoX, origoY, componentWidth, componentHeight, mouseX, mouseY));
        //getPixelsToCoordinates(mouseX, mouseY);

        if (showCoords && (MouseHover.checkMouseHover(origoX, origoY, componentWidth, componentHeight, mouseX, mouseY))) {
            text("X: " + str(getPixelsToCoordinates(mouseX, mouseY)[0]) + " Y: " + str(getPixelsToCoordinates(mouseX, mouseY)[1]), mouseX, mouseY);
        }
    }


    public void mouseDragged() {
        //Called from void mouseDragged() NB: Only left mouse button
        //Positive = move right / down
        if (!canDrag) return;

        int dX = lastMouseCoords[0] - mouseX;
        int dY = mouseY - lastMouseCoords[1];
        
        float dPercentX = float(dX) / float(componentWidth);
        float dPercentY = float(dY) / float(componentHeight);

        int[] viewLength = getViewLength();

        int dXCoords = int(dPercentX * viewLength[0]);
        int dYCoords = int(dPercentY * viewLength[1]);

        setViewX(new int[]{viewOrigin[0] + dXCoords, viewOrigin[1] + dXCoords});
        setViewY(new int[]{viewOrigin[2] + dYCoords, viewOrigin[3] + dYCoords});
        

    }


    public void mousePressed() {
        if(!(MouseHover.checkMouseHover(origoX, origoY, componentWidth, componentHeight, mouseX, mouseY))) return;
        //Called from void mousePressed() NB: Only left mouse button
        viewOrigin = new int[]{viewX[0], viewX[1], viewY[0], viewY[1]};
        lastMouseCoords = new int[]{mouseX, mouseY};
        canDrag = true; 
    }
    

    public void mouseReleased() {
        //Called from void mouseReleased() NB: Only left mouse button
        canDrag = false;
    }


    public void mouseCenter() {
        showCoords = !showCoords;
    }

    
    public int[] getViewX() {
        return viewX;
    }
    
    
    public int[] getViewY() {
        return viewY;
    }
    
    
    public int[] getViewLength() {
        int xLength = viewX[1] - viewX[0];
        int yLength = viewY[1] - viewY[0];
        return new int[]{xLength, yLength};
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
            println("Error: Wrong xRange or yRange length. Returning null");
            return null;
        }
        
        //Find all end keys
        int xMin = xRange[0] / 10 - 1;
        int xMax = xRange[1] / 10 + 1;
        int yMin = yRange[0] / 10 - 1;
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
    
    
    private ArrayList<ArrayList<DataPoint>> getPointListList(String[] keyList) {
        //Talkes a array of string keys and returns corresponding ArrayList<DataPoint> in a new wrapper ArrayList
        ArrayList<ArrayList<DataPoint>> dataPointListList = new ArrayList<ArrayList<DataPoint>>();
        
        for (String key : keyList) {
            ArrayList<DataPoint> dataPointArrayList = storage.getDataPointArrayList(key);
            if (dataPointArrayList != null) dataPointListList.add(dataPointArrayList); //null = no points in cell
        }
        //println(dataPointListList.size());
        return dataPointListList;
    }
    
    
    private int[] getPixelsToCoordinates(int pixelX, int pixelY) {
        //Takes a set of pixels values and return the coordinates 
        int[] viewLength = getViewLength();
        
        int mouseXLength = pixelX - origoX;
        int mouseYLength = pixelY - origoY;
        
        float mouseXPercent = float(mouseXLength) / float(componentWidth);
        float mouseYPercent = 1 - float(mouseYLength) / float(componentHeight);
        
        int coordinateX = int(mouseXPercent * viewLength[0]) + viewX[0];
        int coordinateY = int(mouseYPercent * viewLength[1]) + viewY[0];
        //println("Coordinates: " + coordinateX + " " + coordinateY);
        return new int[]{coordinateX, coordinateY};
    }
    
    
    private int[] geCoordinatesToPixels(int coordinateX, int coordinateY) {
        //Takes a set of coordinates values and return the pixels
        int[] lengths = getViewLength();
        
        int pointX = coordinateX - viewX[0];
        int pointY = coordinateY - viewY[0];

        float pointXPercent = float(pointX) / float(lengths[0]);
        float pointYPercent = 1 - float(pointY) / float(lengths[1]);

        int pixelX = int(pointXPercent * componentWidth) + origoX;
        int pixelY = int(pointYPercent * componentHeight) + origoY;

        return new int[]{pixelX, pixelY};
    }


    private boolean checkMouseHover() {
        return MouseHover.checkMouseHover(origoX, origoY, componentWidth, componentHeight, mouseX, mouseY);
    }
}