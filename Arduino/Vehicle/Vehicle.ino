#include "LED.h"
#include "motor.h"
#include "Definitions.h"

// Begin Jakob indsat
#include <SPI.h>

#include "src/RF24/RF24.h"
#include "src/RF24/nRF24L01.h"
#include "src/RF24/printf.h"

RF24 radio(7, 8);  // CE, CSN
const byte addresses[][6] = {"00001", "00002"};
String toSend;
String lastRecived;
bool newDataToParse = false;

// End Jakob indsat

long tid = 0;
long tid2 = 0;

void setup() {
    // Begin Jakob indsat
    radio.begin();
    radio.openWritingPipe(addresses[0]);     // 00001
    radio.openReadingPipe(1, addresses[1]);  // 00002
    radio.startListening();
    // End Jakob indsat

    delay(1000);

    pins();

    Serial.begin(9600);

    attachInterrupt(digitalPinToInterrupt(interruptPin), left_encoder_trigger, CHANGE);    // Tæller encoderen for venstre hjul
    attachInterrupt(digitalPinToInterrupt(interruptPin2), right_encoder_trigger, CHANGE);  // Tæller encoderen for højre hjul

    // left_motor_speed = 50;
    // right_motor_speed = 40;
    left_motor_speed = 0;
    right_motor_speed = 0;

    left_motor.drive(left_motor_speed);
    right_motor.drive(right_motor_speed);

    Serial.println(wheel_diameter, 4);
    Serial.println(wheel_circumference, 4);
    Serial.println(encoder_measurements);
    Serial.println(measurement_length, 4);
    Serial.println(rotation_diameter);
    Serial.println(rotation_circumference, 4);
    Serial.println(measurement_rotation, 4);
    Serial.println(measurement_forward, 4);
    Serial.println(measurement_sideways, 4);
}

void loop() {
    testRadio();

    /*
      Serial.println("");
      Serial.print("Venstre encoder: ");
      Serial.println(count_left_encoder);
      Serial.print("Højre encoder: ");
      Serial.println(count_right_encoder);
      Serial.print("X-koordinat: ");
      Serial.println(vehicle_X);
      Serial.print("Y-koordinat: ");
      Serial.println(vehicle_Y);
      Serial.print("radianer: ");
      Serial.println(vehicle_angle);
    */

    /*
      switch (state) {
        case 0:
          find_point();
          break;
        case 1:
          get_point();
          break;
        case 112:
          stop_();
          break;
      }

      if ((millis() - speed_change) > 500) {
        Serial.print("venstre ");
        Serial.println(count_left_encoder);
        Serial.print("Højre   ");
        Serial.println(count_right_encoder);
        speed_change = millis();
      }
    */

    if ((millis() - tid2) > 1000) {
        /*
        Serial.print("Højre encoder: ");
        Serial.println(count_right_encoder);
        Serial.print("Venstre encoder: ");
        Serial.println(count_left_encoder);
        Serial.print("Højre motor's hastighed: ");
        Serial.println(right_motor_speed);
        Serial.print("position: (");
        Serial.print(vehicle_X);
        Serial.print(";");
        Serial.print(vehicle_Y);
        Serial.println(")");
        Serial.print("radianer: ");
        Serial.println(vehicle_angle);
        Serial.println("");
    */
        // sendTestPosition();

        tid2 = millis();
    }

    if ((millis() - tid) > 100) {
        if (count_left_encoder < count_right_encoder) {
            right_motor_speed--;
            count_left_encoder = 0;
            count_right_encoder = 0;
        }
        if (count_left_encoder > count_right_encoder) {
            right_motor_speed++;
            count_left_encoder = 0;
            count_right_encoder = 0;
        }
        left_motor.drive(left_motor_speed);
        right_motor.drive(right_motor_speed);

        tid = millis();
    }
}

void left_encoder_trigger() {
    detachInterrupt(digitalPinToInterrupt(interruptPin2));
    count_left_encoder++;
    vehicle_X = vehicle_X + ((sin(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // Der lægges til dens X- og Y-postition afhængig af bilens vinkel. Længden er
    vehicle_Y = vehicle_Y + ((cos(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // afhængig af én måling. Der deles med to, da bilens koordinat er midten hjulene.
    vehicle_angle = vehicle_angle + measurement_rotation;
    attachInterrupt(digitalPinToInterrupt(interruptPin2), right_encoder_trigger, CHANGE);
}

void right_encoder_trigger() {
    count_right_encoder++;
    vehicle_X = vehicle_X + ((sin(vehicle_angle - measurement_rotation) * measurement_length) / 2);
    vehicle_Y = vehicle_Y + ((cos(vehicle_angle - measurement_rotation) * measurement_length) / 2);
    vehicle_angle = vehicle_angle - measurement_rotation;
}

// https://components101.com/microcontrollers/arduino-uno

// Begin Jakob indsat

void sendTestPosition() {
    toSend = "?0;";
    toSend += int(vehicle_X);
    toSend += ";";
    toSend += int(vehicle_Y);
    toSend += ";";
    toSend += int(vehicle_angle);
    toSend += ";-1";
    toSend += "!";
    toSend += char(generateCS(toSend));
    Serial.print(toSend);

    char textToSend[32];
    toSend.toCharArray(textToSend, 32);

    radio.stopListening();
    radio.write(&textToSend, sizeof(textToSend));
    radio.startListening();
}

byte generateCS(String inputStr) {
    byte currentCS = 0;
    for (int i = 0; i < inputStr.length(); i++) {
        currentCS += int(inputStr[i]);
    }
    return currentCS;
}

void testRadio() {
    // Writes recived radio-data to serial and activaes LED
    if (radio.available()) {
        char text[32] = {0};
        radio.read(&text, sizeof(text));
        Serial.println(text);
        digitalWrite(4, HIGH);
        lastRecived = String(text);
        newDataToParse = true;
    }

    if (newDataToParse) {
        if (checkData(lastRecived) != 0) {
            Serial.println(checkData(lastRecived));
            digitalWrite(4, LOW);
            newDataToParse = false;
            left_motor_speed = 0;
            right_motor_speed = 0;
        } else {
            // Good package
            left_motor_speed = 90;
            right_motor_speed = 80;
        }
    }
}

int checkData(String dataToCheck) {
    // 0 = Valid package
    // 1 = Wrong checksum
    // 2 = Fist char is not ´?´
    // 3 = CommandID not number
    // 4 = Wrong command
    // 5 = ';' not found
    // 6 = '!' not found

    int expectedDataLengthArray[] = {0, 2, 0};
    int expectedDataLengthArrayLength = 3;

    byte expectedCS = 0;
    for (int i = 0; i < dataToCheck.length() - 1; i++) {
        expectedCS += int(dataToCheck[i]);
        // Serial.println(dataToCheck[i]);
    }
    byte receivedCS = dataToCheck[dataToCheck.length() - 1];
    if (expectedCS != receivedCS) return 1;

    int index = 0;
    if (dataToCheck[index] != '?') return 2;  // First char must be '?'
    index++;

    if (dataToCheck[index] == '-') index++;        // Skip leeding '-'
    char commandIDStr = char(dataToCheck[index]);  // First character is commadID
    if (!isDigit(commandIDStr)) return 3;          // Must be a number
    int commandID = int(commandIDStr) - 48;        //'0' = 48 in ascii

    if (commandID >= expectedDataLengthArrayLength) return 4;  // Check if command exists
    int expectedDataLength = expectedDataLengthArray[commandID];

    for (int i = 0; i < expectedDataLength; i++) {
        index++;
        if (dataToCheck[index] != ';') return 5;  // Must have a ';' before numbers
        index++;
        if (dataToCheck[index] == '-') index++;  // Skip leeding '-'

        while (true) {
            char currentIntStr = char(dataToCheck[index]);
            if (isDigit(currentIntStr)) {
                index++;
            } else {
                index--;
                break;
            }
        }
    }

    index++;
    if (dataToCheck[index] != '!') return 6;  // End character must be '!'

    Serial.println(dataToCheck);
    Serial.print("expectedCS: ");
    Serial.println(char(expectedCS));
    Serial.print("  int: ");
    Serial.println(expectedCS);

    Serial.print("receivedCS: ");
    Serial.println(char(receivedCS));
    Serial.print("  int: ");
    Serial.println(receivedCS);

    return 0;
}

// End Jakob indsat
