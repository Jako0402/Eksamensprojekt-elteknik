void setup() {
    String words = "apple bear cat dog";
    String[] list = split(words, ' ');
    
    // Writes the strings to a file, each on a separate line
    saveStrings("nouns.txt", list);

    list[0] = "TEST";
    saveStrings("nouns.txt", list);
}