import java.util.*;
import java.util.stream.*;

String[] findNeighbors(String centerKey, int radius) {
    String[] foundNeighbors = {centerKey};
    
    
    //TODO: This is very bad. Fix to linear search
    for (int rIndex = 0; rIndex < radius; rIndex++) {
        
        for (String currentKey : foundNeighbors) {
            
            String[] keys = split(currentKey, ',');
            int[] keysAsInt = {int(keys[0]), int(keys[1])};
            
            for (int i = -1; i < 2; i++) {
                for (int j = -1; j < 2; j++) {
                    if (i == 0 && j == 0) continue; //center
                    String newKeyX = str(keysAsInt[0] + i);
                    String newKeyY = str(keysAsInt[1] + j);
                    
                    //println("Neighbor: " + newKeyX + "," + newKeyY);
                    foundNeighbors = append(foundNeighbors, newKeyX + "," + newKeyY);
                }
            }
        }
    }

    //https://stackoverflow.com/questions/52148400/remove-duplicates-from-a-list-of-string-array/52148554#52148554
    String[] foundNeighborsNoDup = Arrays.stream(foundNeighbors).distinct().toArray(String[]::new);

    return foundNeighborsNoDup;
}

