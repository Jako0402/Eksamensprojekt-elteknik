#include "LED.h"
#include "motor.h"
#include "Definitions.h"

void setup() {

  delay(1000);

  pins();

  Serial.begin(9600);

  attachInterrupt(digitalPinToInterrupt(interruptPin), add, CHANGE);      // Tæller encoderen for venstre hjul
  attachInterrupt(digitalPinToInterrupt(interruptPin2), add2, CHANGE);    // Tæller encoderen for højre hjul

  left_motor_speed = 75;
  right_motor_speed = 65;

  left_motor.drive(left_motor_speed);
  right_motor.drive(right_motor_speed);

}

void loop() {

  switch (state) {
    case 0:
      find_point();
      break;
    case 1:
      point_found();
      break;
    case 2:
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

  /*
    if (count_left_encoder < count_right_encoder) {
      right_motor_speed--;
    }
    if (count_left_encoder > count_right_encoder) {
      right_motor_speed++;
    }
    left_motor.drive(left_motor_speed);
    right_motor.drive(right_motor_speed);
  */

}

void add() {
  count_left_encoder++;
}

void add2() {
  count_right_encoder++;
}

// https://components101.com/microcontrollers/arduino-uno
