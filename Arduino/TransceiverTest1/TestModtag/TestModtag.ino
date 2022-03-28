#include <SPI.h>

#include "src/RF24/RF24.h"
#include "src/RF24/nRF24L01.h"
#include "src/RF24/printf.h"

// create an RF24 object
RF24 radio(7, 8);  // CE, CSN

// address through which two modules communicate.
const byte address[6] = "00001";

void setup() {
    while (!Serial)
        ;
    Serial.begin(9600);

    radio.begin();

    // set the address
    radio.openReadingPipe(0, address);

    // Set module as receiver
    radio.startListening();
}

void loop() {
    // Read the data if available in buffer
    if (radio.available()) {
        char text[32] = {0};
        radio.read(&text, sizeof(text));
        Serial.println(text);
    }
}