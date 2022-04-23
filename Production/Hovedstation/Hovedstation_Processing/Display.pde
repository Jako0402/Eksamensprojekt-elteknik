class Dataviewer extends UIElement implements MouseHover {
    //Draws points and walls
    Storage storage; //Read only DO NOT CHANGE FROM THE CLASS
    int[] viewX = { - 25, 25}; //How far is displayed 
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
        layer = 0; //Dataviewer must be first layer
    }
    
    
    Dataviewer(Storage storage) {
        super();
        this.storage = storage;
        this.cellResolution = storage.getCellResolution();
        layer = 0;
    }
    
    
    @Override
    public void display() {
        fill(150);
        rect(origoX, origoY, componentWidth, componentHeight);
        drawGrid();
        drawWalls();
        drawPoints();
        drawTarget();
        drawPosition();
        
        
        if (showCoords && checkMouseHover()) {
            showCoordsMouse();
        }
    }
    
    
    public void mouseDragged() {
        //Called from void mouseDragged() NB: Only left mouse button
        //Positive = move right / down
        if (!canDrag) return; //Return if dragged started outside viewer
        
        int dX = lastMouseCoords[0] - mouseX; //How far mouse moved
        int dY = mouseY - lastMouseCoords[1];
        
        float dPercentX = float(dX) / float(componentWidth); //percent moved
        float dPercentY = float(dY) / float(componentHeight);
        
        int[] viewLength = getViewLength();
        
        int dXCoords = int(dPercentX * viewLength[0]); //Moved length realtive to view length
        int dYCoords = int(dPercentY * viewLength[1]);
        
        setViewX(new int[]{viewOrigin[0] + dXCoords, viewOrigin[1] + dXCoords}); //Move view
        setViewY(new int[]{viewOrigin[2] + dYCoords, viewOrigin[3] + dYCoords});  
        
    }
    
    
    public void mousePressed() {
        if (!checkMouseHover()) return; //Return if not over viewer
        //Called from void mousePressed() NB: Only left mouse button
        viewOrigin = new int[]{viewX[0], viewX[1], viewY[0], viewY[1]}; //Save current view
        lastMouseCoords = new int[]{mouseX, mouseY}; //save mouse
        canDrag = true; //We can now drag view
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
        if (!checkMouseHover()) return; //return if not hover
        int mouseScrool = event.getCount();
        
        //Limit max and min size and scrool
        if ((mouseScrool < 0 && getViewLength()[0] < 15) || mouseScrool > 0 && getViewLength()[0] > 1000) return;
        
        int scrool = event.getCount() + event.getCount() * (getViewLength()[0] / 50); //Scrool based on view
        //int dScrool = scrool * (getViewLength[0] / 100);
        //println(scrool);
        int[] tempX = getViewX();
        int[] tempY = getViewY();
        setViewX(new int[]{tempX[0] - scrool, tempX[1] + scrool}); //Change view
        setViewY(new int[]{tempY[0] - scrool, tempY[1] + scrool});
    }
    
    
    public int[] getViewX() {
        return viewX;
    }
    
    
    public int[] getViewY() {
        return viewY;
    }
    
    
    public int[] getViewLength() {
        //Return how long from max to min view
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
        //To avoid loosing the outer lines, 1 is added to endkeys
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
        
        //Number of pixel from component origo
        int mouseXLength = pixelX - origoX; 
        int mouseYLength = pixelY - origoY;
        
        //Percent of component (NB: '1-' is used because coordinates are reversed compared to processing coordinates)
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
        
        //How far from lowest x- and y- coordiante
        int pointX = coordinateX - viewX[0];
        int pointY = coordinateY - viewY[0];
        
        //Percentage compared to max view length
        float pointXPercent = float(pointX) / float(lengths[0]);
        float pointYPercent = 1 - float(pointY) / float(lengths[1]);
        
        int pixelX = int(pointXPercent * componentWidth) + origoX;
        int pixelY = int(pointYPercent * componentHeight) + origoY;
        
        return new int[]{pixelX, pixelY};
    }
    
    
    private boolean checkMouseHover() {
        //Returns true if mouse is over component
        return MouseHover.checkMouseHover(origoX, origoY, componentWidth, componentHeight, mouseX, mouseY);
    }
    
    
    private void showCoordsMouse() {
        //Shows mouse coodinates above mouse. Used to check point coordinates
        fill(0);
        text("X: " + str(getPixelsToCoordinates(mouseX, mouseY)[0]) + " Y: " + str(getPixelsToCoordinates(mouseX, mouseY)[1]), mouseX, mouseY);
    }
    
    
    private void drawGrid() {
        //Draws the grindlines
        stroke(Colors.get("gridLine"));
        int endKeys[] = calculateEndKeys(viewX, viewY); //xMin, xMax, yMin, yMax
        
        //Vertical lines
        for (int xLine = endKeys[0]; xLine <= endKeys[1]; xLine++) {
            //Draw a line for each cell
            int[] point1 = getCoordinatesToPixels(xLine * 10, endKeys[2] * 10);
            int[] point2 = getCoordinatesToPixels(xLine * 10, endKeys[3] * 10);
            layers[layer].line(point1[0], point1[1], point2[0], point2[1]);
        }
        
        //Horizontal lines
        for (int yLine = endKeys[2]; yLine <= endKeys[3]; yLine++) {
            //Draw a line for each cell
            int[] point1 = getCoordinatesToPixels(endKeys[0] * 10, yLine * 10);
            int[] point2 = getCoordinatesToPixels(endKeys[1] * 10, yLine * 10);
            layers[layer].line(point1[0], point1[1], point2[0], point2[1]);
        }
    }
    
    
    private void drawPoints() {
        //Draws the dataPoints

        //Calculate key-list based on current view
        String[] keys = calculateKeyList(viewX, viewY, cellResolution);
        ArrayList<ArrayList<DataPoint>> listList = getPointListList(keys);
        
        //Loop through each Datapoint and draw point
        for (ArrayList < DataPoint > list : listList) {
            for (DataPoint dp : list) {
                
                //Colour based on datapoint
                stroke(Colors.get("outline")); 
                if (dp.getObstacle()) {
                    fill(Colors.get("obstaclePoint"));
                } else{
                    fill(Colors.get("clearPoint"));
                }
                
                int[] coords = getCoordinatesToPixels(dp.getXpos(), dp.getYpos());
                circle(coords[0], coords[1], calculatePointSize(5)); //Size based on view and windows size
            }
        }
    }
    
    
    private void drawWalls() {
        //Draws the walls based on storage
        ArrayList<WallSegment> wallList = storage.getWallsList();
        if (wallList == null) return;
        
        //Loop thrugh and draw
        for (WallSegment ws : wallList) {
            int[] point1 = ws.getPoint1();
            int[] point2 = ws.getPoint2();
            stroke(Colors.get("walls"));
            //println("Wall: " + point1[0] + " " + point1[1] + " " + point2[0] + " " + point2[1]);
            int[] coords1 = getCoordinatesToPixels(point1[0], point1[1]);
            int[] coords2 = getCoordinatesToPixels(point2[0], point2[1]);
            strokeWeight(calculatePointSize(1));
            line(coords1[0], coords1[1], coords2[0], coords2[1]);
            strokeWeight(1);
        }
    }
    
    
    private void drawTarget() {
        //Draw target
        int[] target = storage.getCurrentTarget();
        int[] coords = getCoordinatesToPixels(target[0], target[1]);
        fill(Colors.get("targetPoint"));
        circle(coords[0], coords[1], calculatePointSize(7));
    }
    
    
    private void drawPosition() {
        //Draw current position

        //Get latest point and find pixel-position
        DataPoint lastPosDP = storage.getLastDataPoint();
        int[] vehiclePos = new int[]{lastPosDP.getXpos(), lastPosDP.getYpos()};
        int[] coords = getCoordinatesToPixels(vehiclePos[0], vehiclePos[1]);
        //println("draw pos: " + vehiclePos[0] + " " + vehiclePos[1]);

        //Draw point as a triangle
        pushMatrix();
        translate(coords[0], coords[1]);
        float angleRad = lastPosDP.getAngle() * (PI / 180);
        rotate(-angleRad);
        fill(Colors.get("positionPoint")); 
        triangle(calculatePointSize(25), 0,
                 -calculatePointSize(10), calculatePointSize(5), 
                 -calculatePointSize(10), -calculatePointSize(5));
        popMatrix();
        circle(coords[0], coords[1], calculatePointSize(5));
    }
    
    
    private int calculatePointSize(int startSize) {
        //Uses view length and window width 
        int viewLengthAjust = int(float(startSize) + (1000 / float(getViewLength()[0])));
        int frameAjust = int(float(viewLengthAjust) * (float(width) / float(1080)));
        return frameAjust;
    }
}