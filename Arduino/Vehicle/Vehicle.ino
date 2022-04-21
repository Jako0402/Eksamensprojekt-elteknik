#include "LED.h"
#include "motor.h"
#include "Definitions.h"

// Begin Jakob indsat
#include <SPI.h>

#include "src/RF24/RF24.h"
#include "src/RF24/nRF24L01.h"
#include "src/RF24/printf.h"

RF24 radio(7, 8);  // CE, CSN
const byte stationAddress[6] = "00001";
const byte vehicleAddress[6] = "00002";
String toSend;
String lastRecived;
int commandArr[5];
int arrLenth;
int contactStatus = -1;
// End Jakob indsat

long tid = 0;
long tid2 = 0;


void setup() {
  // Begin Jakob indsat
  radio.begin();
  radio.openWritingPipe(stationAddress);     // 00001
  radio.openReadingPipe(1, vehicleAddress);  // 00002
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

  /*
      Serial.println(wheel_diameter, 4);
      Serial.println(wheel_circumference, 4);
      Serial.println(encoder_measurements);
      Serial.println(measurement_length, 4);
      Serial.println(rotation_diameter);
      Serial.println(rotation_circumference, 4);
      Serial.println(measurement_rotation, 4);
      Serial.println(measurement_forward, 4);
      Serial.println(measurement_sideways, 4);
  */
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
    // sendPosition();

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
  if (left_motor_speed > 0) {
    vehicle_X += ((sin(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // Der lægges til dens X- og Y-postition afhængig af bilens vinkel.
    vehicle_Y += ((cos(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // afhængig af én måling. Der deles med to, da bilens koordinat er midten hjulene.
    vehicle_angle += measurement_rotation;
  } else {
    vehicle_X -= ((sin(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // Der trækkes fra dens X- og Y-postition afhængig af bilens vinkel.
    vehicle_Y -= ((cos(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // afhængig af én måling. Der deles med to, da bilens koordinat er midten hjulene.
    vehicle_angle -= measurement_rotation;
  }
  attachInterrupt(digitalPinToInterrupt(interruptPin2), right_encoder_trigger, CHANGE);
}


void right_encoder_trigger() {
  count_right_encoder++;
  if (right_motor_speed > 0) {
    vehicle_X += ((sin(vehicle_angle - measurement_rotation) * measurement_length) / 2);
    vehicle_Y += ((cos(vehicle_angle - measurement_rotation) * measurement_length) / 2);
    vehicle_angle -= measurement_rotation;
  } else {
    vehicle_X -= ((sin(vehicle_angle - measurement_rotation) * measurement_length) / 2);
    vehicle_Y -= ((cos(vehicle_angle - measurement_rotation) * measurement_length) / 2);
    vehicle_angle += measurement_rotation;
  }

}

// https://components101.com/microcontrollers/arduino-uno

// Begin Jakob indsat

void sendPosition() {
  // Sends data (respons nr. 0)
  toSend = "?0;";
  toSend += int(vehicle_X);
  toSend += ";";
  toSend += int(vehicle_Y);
  toSend += ";";
  toSend += int(int(vehicle_angle * (360 / (2 * PI))));   //omregner til grader
  toSend += ";";
  toSend += contactStatus;
  toSend += "!";
  toSend += char(generateCS(toSend));
  //Serial.print(toSend);

  pushStuff();

}


void pushStuff() {
  delay(100);
  char textToSend[32];
  toSend.toCharArray(textToSend, 32);

  radio.stopListening();
  radio.write(&textToSend, sizeof(textToSend));
  radio.startListening();
  Serial.println(textToSend);
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
    status_led.on();
    lastRecived = String(text);

    if (checkData(lastRecived) != 0) {
      Serial.println(checkData(lastRecived));
      status_led.off();

    } else {
      // Good package
      splitGoodPackage();
      handleCommand();
    }
  }
}


bool handleCommand() {
  int commandID = commandArr[0];
  switch (commandID) {
    case 0:
      Serial.println("Command 0");
      if (arrLenth != 0 + 1) return false;
      sendPosition();
      break;

    case 1:
      Serial.println("Command 1");
      if (arrLenth != 2 + 1) return false;
      setNewTarget(commandArr[1], commandArr[2]);
      break;

    case 2:
      Serial.println("Command 2");
      if (arrLenth != 0 + 1) return false;
      stopDriving();
      break;

    default:
      Serial.println("Wrong command ID");
      break;
  }
}


void stopDriving() {        //Stopper bilen
  left_motor_speed = 0;
  right_motor_speed = 0;

  toSend = "?2!";
  toSend += char(generateCS(toSend));
  pushStuff();
}


void setNewTarget(int targetX, int targetY) {       //Sigter efter et nyt punkt, som Processing sender
  Serial.print("New target: ");
  Serial.print(targetX);
  Serial.print(" and ");
  Serial.println(targetY);
  left_motor_speed = 80;
  right_motor_speed = 70;


  toSend  = "?1;";
  toSend += targetX;
  toSend += ";";
  toSend += targetY;
  toSend += "!";
  toSend += char(generateCS(toSend));
  pushStuff();
}


// https://stackoverflow.com/questions/9072320/split-string-into-string-array
void splitGoodPackage() {
  String trimmedPackage = lastRecived.substring(1, lastRecived.length() - 2); //?2!? --> 2
  trimmedPackage += ';';
  // Serial.println(trimmedPackage);

  // Split command at ';'
  // int commandArr[5];

  int begin = 0;
  int index = 0;
  //arrLenth = 0;

  for (int i = 0; i < trimmedPackage.length(); i++) {
    if (trimmedPackage[i] == ';') {
      commandArr[index] = trimmedPackage.substring(begin, i).toInt();
      begin = (1 + i);
      index++;
    }
  }
  arrLenth = index;
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

// End Jakob indsat
