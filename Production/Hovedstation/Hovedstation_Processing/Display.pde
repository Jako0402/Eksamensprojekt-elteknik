class Dataviewer extends UIElement implements MouseHover {
    Storage storage; //Read only
    int[] viewX = { - 25, 25};
    int[] viewY = { - 25, 25};
    int[] viewOrigin;
    int[] lastMouseCoords;
    int cellResolution; //Must match Storage object
    boolean canDrag = false;
    boolean showCoords = true;
    
    
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
        drawGrid();
        drawPoints();
        drawWalls();
        drawTarget();
        drawPosition();
        
        
        if (showCoords && checkMouseHover()) {
            showCoordsMouse();
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
        if (!checkMouseHover()) return;
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
        //Called when mouse wheel pressed
        if (!checkMouseHover()) return;
        showCoords = !showCoords;
    }
    
    
    public void mouseWheel(MouseEvent event) {
        //Called when scrool
        if (!checkMouseHover()) return;
        int scrool = event.getCount();
        //int dScrool = scrool * (getViewLength[0] / 100);
        //println(scrool);
        int[] tempX = getViewX();
        int[] tempY = getViewY();
        setViewX(new int[]{tempX[0] - scrool, tempX[1] + scrool});
        setViewY(new int[]{tempY[0] - scrool, tempY[1] + scrool});
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
        int endKeys[] = calculateEndKeys(xRange, yRange); //xMin, xMax, yMin, yMax
        
        //Loop and append keys
        for (int tempXKey = endKeys[0]; tempXKey <= endKeys[1]; tempXKey++) {
            for (int tempYKey = endKeys[2]; tempYKey <= endKeys[3]; tempYKey++) {
                foundKeys = append(foundKeys, str(tempXKey) + "," + str(tempYKey));
            }
        }
        
        return foundKeys;
    }
    
    
    private int[] calculateEndKeys(int[] xRange, int[] yRange) {
        int xMin = xRange[0] / cellResolution - 1;
        int xMax = xRange[1] / cellResolution + 1;
        int yMin = yRange[0] / cellResolution - 1;
        int yMax = yRange[1] / cellResolution + 1;
        return new int[] {xMin, xMax, yMin, yMax};
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
    
    
    private int[] getCoordinatesToPixels(int coordinateX, int coordinateY) {
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
    
    
    private void showCoordsMouse() {
        fill(0);
        text("X: " + str(getPixelsToCoordinates(mouseX, mouseY)[0]) + " Y: " + str(getPixelsToCoordinates(mouseX, mouseY)[1]), mouseX, mouseY);
    }
    
    
    private void drawGrid() {
        stroke(135);
        int endKeys[] = calculateEndKeys(viewX, viewY); //xMin, xMax, yMin, yMax
        
        //Vertical lines
        for (int xLine = endKeys[0]; xLine <= endKeys[1]; xLine++) {
            int[] point1 = getCoordinatesToPixels(xLine * 10, endKeys[2] * 10);
            int[] point2 = getCoordinatesToPixels(xLine * 10, endKeys[3] * 10);
            line(point1[0], point1[1], point2[0], point2[1]);
        }
        
        //Horizontal lines
        for (int yLine = endKeys[2]; yLine <= endKeys[3]; yLine++) {
            int[] point1 = getCoordinatesToPixels(endKeys[0] * 10, yLine * 10);
            int[] point2 = getCoordinatesToPixels(endKeys[1] * 10, yLine * 10);
            line(point1[0], point1[1], point2[0], point2[1]);
        }
        
    }
    
    
    private void drawPoints() {
        String[] keys = calculateKeyList(viewX, viewY, cellResolution);
        ArrayList<ArrayList<DataPoint>> listList = getPointListList(keys);
        
        for (ArrayList < DataPoint > list : listList) {
            for (DataPoint dp : list) {

                //Colour based on datapoint 
                if (dp.getObstacle()) {
                    fill(Colors.get("obstaclePoint"));
                } else{
                     fill(Colors.get("clearPoint"));
                }
                
                int[] coords = getCoordinatesToPixels(dp.getXpos(), dp.getYpos());
                circle(coords[0], coords[1], 10);
            }
        }
    }
    
    
    private void drawWalls() {
        ArrayList<WallSegment> wallList = storage.getWallsList();
        if (wallList == null) return;
        
        for (WallSegment ws : wallList) {
            int[] point1 = ws.getPoint1();
            int[] point2 = ws.getPoint2();
            stroke(0);
            //println("Wall: " + point1[0] + " " + point1[1] + " " + point2[0] + " " + point2[1]);
            int[] coords1 = getCoordinatesToPixels(point1[0], point1[1]);
            int[] coords2 = getCoordinatesToPixels(point2[0], point2[1]);
            line(coords1[0], coords1[1], coords2[0], coords2[1]);
        }
    }
    
    
    private void drawTarget() {
        int[] target = storage.getCurrentTarget();
        int[] coords = getCoordinatesToPixels(target[0], target[1]);
        circle(coords[0], coords[1], 15);
    }
    
    
    private void drawPosition() {
        DataPoint lastPosDP = storage.getLastDataPoint();
        int[] vehiclePos = new int[]{lastPosDP.getXpos(), lastPosDP.getYpos()};
        int[] coords = getCoordinatesToPixels(vehiclePos[0], vehiclePos[1]);
        //println("draw pos: " + vehiclePos[0] + " " + vehiclePos[1]);
        circle(coords[0], coords[1], 25);
    }
}