#include "LED.h"
#include "motor.h"
#include "Definitions.h"


//Begin Jakob indsat
#include <SPI.h>
#include "src/RF24/RF24.h"
#include "src/RF24/nRF24L01.h"
#include "src/RF24/printf.h"

RF24 radio(7, 8);  // CE, CSN
String toSend;
const byte addresses[][6] = {"00001", "00002"};
//End Jakob indsat

long tid = 0;
long tid2 = 0;

void setup() {
  //Begin Jakob indsat
  radio.begin();
  radio.openWritingPipe(addresses[0]);     // 00001
  radio.openReadingPipe(1, addresses[1]);  // 00002
  radio.startListening();
  //End Jakob indsat

  delay(1000);

  pins();

  Serial.begin(9600);

  attachInterrupt(digitalPinToInterrupt(interruptPin), left_encoder_trigger, CHANGE);      // Tæller encoderen for venstre hjul
  attachInterrupt(digitalPinToInterrupt(interruptPin2), right_encoder_trigger, CHANGE);    // Tæller encoderen for højre hjul

  left_motor_speed = 50;
  right_motor_speed = 40;

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
    sendTestPosition();

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

void left_encoder_trigger () {
  detachInterrupt(digitalPinToInterrupt(interruptPin2));
  count_left_encoder++;
  vehicle_X = vehicle_X + ((sin(vehicle_angle + measurement_rotation) * measurement_length) / 2); //Der lægges til dens X- og Y-postition afhængig af bilens vinkel. Længden er
  vehicle_Y = vehicle_Y + ((cos(vehicle_angle + measurement_rotation) * measurement_length) / 2); //afhængig af én måling. Der deles med to, da bilens koordinat er midten hjulene.
  vehicle_angle = vehicle_angle + measurement_rotation;
  attachInterrupt(digitalPinToInterrupt(interruptPin2), right_encoder_trigger, CHANGE);
}

void right_encoder_trigger () {
  count_right_encoder++;
  vehicle_X = vehicle_X + ((sin(vehicle_angle - measurement_rotation) * measurement_length) / 2);
  vehicle_Y = vehicle_Y + ((cos(vehicle_angle - measurement_rotation) * measurement_length) / 2);
  vehicle_angle = vehicle_angle - measurement_rotation;
}

// https://components101.com/microcontrollers/arduino-uno


//Begin Jakob indsat

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
  if (radio.available()) {
    char text[32] = {0};
    radio.read(&text, sizeof(text));
    Serial.println(text);
    digitalWrite(4, HIGH);
    delay(200);
    digitalWrite(4, LOW);
  }
}


//End Jakob indsat