void calculateTarget() {
    println("calculate new taget");
    if (lastPos[0] / 10 == lastObs[0] / 10 && lastPos[1] / 10 == lastObs[1] / 10) {
        println("Same square ");
        float dx = 15 * sin(lastObsAngle * (PI / 180));
        float dy = 15 * cos(lastObsAngle * (PI / 180));
        println("dx: " + dx + " - dy: " + dy);
        
        target[0] = lastObs[0] + int( -dx);
        target[1] = lastObs[1] + int( -dy);
    } else if (dist(lastPos[0], lastPos[1], lastObs[0], lastObs[1]) < 30) {
        float newAngle = lastObsAngle + 90;
        float dx = 30 * sin(newAngle * (PI / 180));
        float dy = 30 * cos(newAngle * (PI / 180));
        println("dx: " + dx + " - dy: " + dy);
        
        target[0] = lastPos[0] + int( -dx);
        target[1] = lastPos[1] + int( - dy);
    } else{
        float newAngle = lastObsAngle - 90;
        float dx = 30 * cos(newAngle * (PI / 180));
        float dy = 30 * sin(newAngle * (PI / 180));
        println("dx: " + dx + " - dy: " + dy);
        
        target[0] = lastPos[0] + int( -dx);
        target[1] = lastPos[1] + int( - dy);  
    }
}