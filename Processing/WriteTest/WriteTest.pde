void setup() {
    String words = "apple bear cat dog";
    String[] list = split(words, ' ');
    
    // Writes the strings to a file, each on a separate line
    saveStrings("nouns.txt", list);
    
    list[0] = "TEST";
    saveStrings("nouns.txt", list);
    
    
    
    
    String[] lines = loadStrings("nouns.txt");
    println("there are " + lines.length + " lines");
    for (int i = 0; i < lines.length; i++) {
        println(lines[i]);
    }
}