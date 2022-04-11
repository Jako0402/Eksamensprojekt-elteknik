#include <SPI.h>

#include "src/RF24/RF24.h"
#include "src/RF24/nRF24L01.h"
#include "src/RF24/printf.h"

// create an RF24 object
RF24 radio(7, 8);  // CE, CSN

long maxTimeSerial = 500;

String stringFromPC;

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
    radio.openReadingPipe(1, addresses[1]);  // 00002

    radio.stopListening();
}

void loop() {
    if (radio.available()) {
        char text[32] = {0};
        radio.read(&text, sizeof(text));
        //Serial.print(text);
        digitalWrite(4, HIGH);
        checkData(String(text));
    }

    if (Serial.available() > 0) {
        stringFromPC = Serial.readString();

        stringFromPC += char(generateCS(stringFromPC));
        //Serial.println(stringFromPC + " " + stringFromPC.length());

        char textToSend[32];
        stringFromPC.toCharArray(textToSend, 32);

        radio.stopListening();
        radio.write(&textToSend, sizeof(textToSend));
        radio.startListening();
        digitalWrite(4, LOW);
    }
}

byte generateCS(String inputStr) {
    byte currentCS = 0;
    for (int i = 0; i < inputStr.length(); i++) {
        currentCS += int(inputStr[i]);
    }
    return currentCS;
}

int checkData(String dataToCheck) {
    byte expectedCS = 0;
    for (int i = 0; i < dataToCheck.length()-1; i++) {
        expectedCS += int(dataToCheck[i]);
        Serial.println(dataToCheck[i]);
    }
    byte receivedCS = dataToCheck[dataToCheck.length()-1];

/*
    Serial.println(dataToCheck);
    Serial.print("expectedCS: ");
    Serial.println(char(expectedCS));
    Serial.print("  int: ");
    Serial.println(expectedCS);

    Serial.print("receivedCS: ");
    Serial.println(char(receivedCS));
    Serial.print("  int: ");
    Serial.println(receivedCS);
*/
    return 0;
}