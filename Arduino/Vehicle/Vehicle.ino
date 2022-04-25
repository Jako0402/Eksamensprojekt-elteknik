#include "LED.h"
#include "motor.h"
#include "Definitions.h"

void setup() {
  radio.begin();
  radio.openWritingPipe(stationAddress);     // 00001
  radio.openReadingPipe(1, vehicleAddress);  // 00002
  radio.startListening();

  pins();

  Serial.begin(9600);

  attachInterrupt(digitalPinToInterrupt(interruptPin), left_encoder_trigger, CHANGE);    // Tæller encoderen for venstre hjul
  attachInterrupt(digitalPinToInterrupt(interruptPin2), right_encoder_trigger, CHANGE);  // Tæller encoderen for højre hjul

  left_motor.drive(vehicle_speed);
  right_motor.drive(right_motor_speed);
}

unsigned long test_tid = 0;

void loop() {

<<<<<<< HEAD
  switch (state) {
    case 0:
      if (millis() - test_tid > 100) {
        Serial.println("State 0");
        test_tid = millis();
      }
      testRadio();
      break;
    case 1:
      if (millis() - test_tid > 100) {
        Serial.println("State 1");
        test_tid = millis();
      }
      aim_at_point(target_X, target_Y);
      break;
    case 2:
      if (millis() - test_tid > 100) {
        Serial.println("State 2");
        test_tid = millis();
      }
      find_point();
    case 3:
      if (millis() - test_tid > 100) {
        Serial.println("State 3");
        test_tid = millis();
      }
      point_found();
      break;
  }
=======
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


>>>>>>> 0d550c0fe372b87b111f5b5208a754098cdbc280
}


void left_encoder_trigger() {
  detachInterrupt(digitalPinToInterrupt(interruptPin2));
  count_left_encoder++;
  left_motor_calibrator++;
  if (vehicle_speed > 0) {
    vehicle_X += ((sin(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // Der lægges til dens X- og Y-postition afhængig af bilens vinkel.
    vehicle_Y += ((cos(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // afhængig af én måling. Der deles med to, da bilens koordinat er midten hjulene.
    vehicle_angle += measurement_rotation;
  } else if (vehicle_speed < 0) {
    vehicle_X -= ((sin(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // Der trækkes fra dens X- og Y-postition afhængig af bilens vinkel.
    vehicle_Y -= ((cos(vehicle_angle + measurement_rotation) * measurement_length) / 2);  // afhængig af én måling. Der deles med to, da bilens koordinat er midten hjulene.
    vehicle_angle -= measurement_rotation;
  }
  attachInterrupt(digitalPinToInterrupt(interruptPin2), right_encoder_trigger, CHANGE);
}


void right_encoder_trigger() {
  count_right_encoder++;
  right_motor_calibrator++;
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

void check_status () {
  if (contactStatus = -1) {  //Ingen forhindring - klar til ny kommando
    vehicle_stop();
    sendPosition();
  }
  if (contactStatus = 0) {   //Ingen forhindring - kører endnu
    sendPosition();
  }
  if (contactStatus <= 5 && contactStatus >= 1) { //forhindring opdaget - klar til ny kommando
    send_point_found();
  }
}

void sendPosition() {
  // Sends data (respons nr. 0)
  toSend = "?0;";
  toSend += int(vehicle_X);
  toSend += ";";
  toSend += int(vehicle_Y);
  toSend += ";";
  toSend += int(int(vehicle_angle * (360 / (2 * PI))));   //omregner radianer til grader
  toSend += ";";
  toSend += contactStatus;
  toSend += "!";
  toSend += char(generateCS(toSend));
  //Serial.print(toSend);

  pushStuff();
}

void send_point_found () {
  // Sends data (respons nr. 1 - 5)
  toSend = "?";
  toSend += int(0);
  toSend += ";";
  toSend += int(point_found_X);
  toSend += ";";
  toSend += int(point_found_Y);
  toSend += ";";
  toSend += int(int(vehicle_angle * (360 / (2 * PI))));   //omregner til grader
  toSend += ";";
  toSend += contactStatus;
  toSend += "!";
  toSend += char(generateCS(toSend));

  pushStuff();
}

void pushStuff() {
  delay(50);
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


bool handleCommand() {
  int commandID = commandArr[0];
  switch (commandID) {
    case 0:
      Serial.println("Command 0");
      if (arrLenth != 0 + 1) return false;
      check_status();
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
  vehicle_speed = 0;
  right_motor_speed = 0;

  toSend = "?2!";
  toSend += char(generateCS(toSend));
  pushStuff();
}


void setNewTarget(int targetX, int targetY) {       //Sigter efter et nyt punkt, som Processing sender

  vehicle_stop();

  target_X = targetX;
  target_X = targetY;
  
  Serial.print("New target: ");
  Serial.print(targetX);
  Serial.print(" and ");
  Serial.println(targetY);

  toSend = "?1;";
  toSend += targetX;
  toSend += ";";
  toSend += targetY;
  toSend += "!";
  toSend += char(generateCS(toSend));
  pushStuff();

  delta_X = vehicle_X - targetX;
  delta_Y = vehicle_Y - targetY;

  distance_to_point = sqrt((delta_X * delta_X) + (delta_Y * delta_Y));

  state = 1;  //sigter efter punkt
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
  target_X = commandArr[2];
  target_Y = commandArr[3];
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

  return 0;
}

void drive_forward() {  //Kører ligeud - regulerer højre hjuls hastighed imens
  if (millis() - last_speed_change > 100) {               //Er der gået 100 ms siden sidste hastighedsændring?
    if (left_motor_calibrator < right_motor_calibrator) { //Er det højre hjul hurtigere end det venstre?
      right_motor_speed--;
    } else if (left_motor_calibrator > right_motor_calibrator) {  //Er det højre hjul langsommere end det venstre?
      right_motor_speed++;
    }
    if (vehicle_speed < 0) {  //Søger for at venstre hjul drejer rigtige vej rundt
      vehicle_speed = -vehicle_speed;
    }
    if (right_motor_speed < 0) {  //Søger for at højre hjul drejer rigtige vej rundt
      right_motor_speed = -right_motor_speed;
    }
    left_motor.drive(vehicle_speed);
    right_motor.drive(right_motor_speed);
    last_speed_change = millis();
    left_motor_calibrator = 0;
    right_motor_calibrator = 0;
  }
}

void drive_backward() {  //Kører baggud - regulerer højre hjuls hastighed imens
  if (millis() - last_speed_change > 100) {               //Er der gået 100 ms siden sidste hastighedsændring?
    if (left_motor_calibrator < right_motor_calibrator) { //Er det højre hjul hurtigere end det venstre?
      right_motor_speed--;
    } else if (left_motor_calibrator > right_motor_calibrator) {  //Er det højre hjul langsommere end det venstre?
      right_motor_speed++;
    }
    if (vehicle_speed > 0) {  //Søger for at venstre hjul drejer baglæns
      vehicle_speed = -vehicle_speed;
    }
    if (right_motor_speed > 0) {  //Søger for at højre hjul drejer baglæns
      right_motor_speed = -right_motor_speed;
    }
    left_motor.drive(vehicle_speed);
    right_motor.drive(right_motor_speed);
    last_speed_change = millis();
    left_motor_calibrator = 0;
    right_motor_calibrator = 0;
  }
}

void turn_left() {  //Drejer mod venstre - regulerer højre hjuls hastighed imens
  if (millis() - last_speed_change > 100) {               //Er der gået 100 ms siden sidste hastighedsændring?
    if (left_motor_calibrator < right_motor_calibrator) { //Er det højre hjul hurtigere end det venstre?
      right_motor_speed--;
    } else if (left_motor_calibrator > right_motor_calibrator) {  //Er det højre hjul langsommere end det venstre?
      right_motor_speed++;
    }
    if (vehicle_speed < 0) {  //Søger for at venstre hjul drejer fremmad
      vehicle_speed = -vehicle_speed;
    }
    if (right_motor_speed > 0) {  //Søger for at højre hjul drejer baglæns
      right_motor_speed = -right_motor_speed;
    }
    left_motor.drive(vehicle_speed);
    right_motor.drive(right_motor_speed);
    last_speed_change = millis();
    left_motor_calibrator = 0;
    right_motor_calibrator = 0;
  }
}

void turn_right() {  //Drejer mod højre - regulerer højre hjuls hastighed imens
  if (millis() - last_speed_change > 100) {               //Er der gået 100 ms siden sidste hastighedsændring?
    if (left_motor_calibrator < right_motor_calibrator) { //Er det højre hjul hurtigere end det venstre?
      right_motor_speed++;
    } else if (left_motor_calibrator > right_motor_calibrator) {  //Er det højre hjul langsommere end det venstre?
      right_motor_speed--;
    }
    Serial.println(right_motor_speed);
    if (vehicle_speed < 0) {  //Søger for at venstre hjul drejer fremmad
      vehicle_speed = -vehicle_speed;
    }
    if (right_motor_speed > 0) {  //Søger for at højre hjul drejer fremmad
      right_motor_speed = -right_motor_speed;
    }
    left_motor.drive(vehicle_speed);
    right_motor.drive(right_motor_speed);
    last_speed_change = millis();
    left_motor_calibrator = 0;
    right_motor_calibrator = 0;
  }
}

void vehicle_stop() { //Stopper køretøjet
  left_motor.drive(0);
  right_motor.drive(0);
}
