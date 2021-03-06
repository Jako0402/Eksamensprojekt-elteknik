#include <SPI.h>

#include "src/RF24/RF24.h"
#include "src/RF24/nRF24L01.h"
#include "src/RF24/printf.h"

// create an RF24 object
RF24 radio(7, 8);  // CE, CSN

String stringFromPC = "";

long maxTimeSerial = 500;

// address through which two modules communicate.
const byte addresses[][6] = {"00001", "00002"};

void setup() {
    Serial.begin(9600);
    Serial.setTimeout(maxTimeSerial);

    radio.begin();

    // set the address
    radio.openReadingPipe(0, addresses[0]);  // 00001
    radio.openWritingPipe(addresses[1]);     // 00002

    // Set module as receiver
    radio.startListening();
}

void loop() {
    if (radio.available()) {
        char text[32] = {0};
        radio.read(&text, sizeof(text));
        Serial.print(text);
    }

    if (Serial.available() > 0) {
        stringFromPC = Serial.readString();
        //Serial.print(stringFromPC); //Debug: Sends a copy of data back to PC

        char textToSend[32];
        stringFromPC.toCharArray(textToSend, 32);

        radio.stopListening();
        radio.write(&textToSend, sizeof(textToSend));
        radio.startListening();
    }
}
