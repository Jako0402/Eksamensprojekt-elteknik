#include <SPI.h>

#include "src/RF24/RF24.h"
#include "src/RF24/nRF24L01.h"
#include "src/RF24/printf.h"

// create an RF24 object
RF24 radio(7, 8);  // CE, CSN

long maxTimeSerial = 500;

// address through which two modules communicate.
const byte addresses[][6] = {"00001", "00002"};

void setup() {
    pinMode(10, OUTPUT);
    digitalWrite(10, LOW);
    pinMode(4, OUTPUT);

    Serial.begin(9600);
    radio.begin();

    // set the address openReadingPipe
    radio.openWritingPipe(addresses[0]);     // 00001
    //radio.openReadingPipe(1, addresses[1]);  // 00002

    radio.stopListening();
}

void loop() {
    /*
    if (radio.available()) {
        char text[32] = {0};
        radio.read(&text, sizeof(text));
        Serial.print(text);
        digitalWrite(4, HIGH);
    }*/

    digitalWrite(4, HIGH);
    const char text[] = "?1;2;3!g";
    radio.write(&text, sizeof(text));
    delay(500);
    digitalWrite(4, LOW);
    delay(500);
}
