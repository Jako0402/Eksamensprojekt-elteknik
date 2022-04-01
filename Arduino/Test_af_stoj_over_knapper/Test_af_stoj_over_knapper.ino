const byte interruptPin = 2;               // Højre encoder
const byte interruptPin2 = 3;              // Venstre encoder
const byte STATUS_LED_PIN = 4;             // Status LED
const byte LEFT_MOTOR_FORWARD_PIN = 5;     // Venstre LED
const byte LEFT_MOTOR_BACKWARD_PIN = 6;    // Venstre LED
const byte RIGHT_MOTOR_FORWARD_PIN = 9;    // Højre LED
const byte RIGHT_MOTOR_BACKWARD_PIN = 10;  // Højre LED
const byte KNAP1_PIN = A0;                 // Venstre knap      //A0 = 14
const byte KNAP2_PIN = A1;                 // Midt-venstre knap //A1 = 15
const byte KNAP3_PIN = A2;                 // Midt knap         //A2 = 16
const byte KNAP4_PIN = A3;                 // Midt-højre knap   //A3 = 17
const byte KNAP5_PIN = A4;                 // Højre knap        //A4 = 18

long count_left_encoder = 0;   // Tæller af venstre encoder
long count_right_encoder = 0;  // Tæller af højre encoder

#include "LED.h"
#include "motor.h"

motor left_motor(LEFT_MOTOR_FORWARD_PIN, LEFT_MOTOR_BACKWARD_PIN);     // Styre venstre motor
motor right_motor(RIGHT_MOTOR_FORWARD_PIN, RIGHT_MOTOR_BACKWARD_PIN);  // Styre højre motor

LED status_led(STATUS_LED_PIN);  // Styre status LED'en

void setup() {
  pins();

  Serial.begin(9600);

  attachInterrupt(digitalPinToInterrupt(interruptPin), add, CHANGE);    // Tæller encoderen for venstre hjul
  attachInterrupt(digitalPinToInterrupt(interruptPin2), add2, CHANGE);  // Tæller encoderen for højre hjul

  left_motor.forward(150);
  right_motor.forward(150);
}

void loop() {

  for (int i = 2; i < 3; i++) {
    if (digitalRead(14 + i) == HIGH) {
      left_motor.forward(0);
      right_motor.forward(0);
      Serial.println(" ");
      Serial.print("FEJL Knap ");
      Serial.print(i + 1);
      Serial.print(" = ");
      Serial.println(analogRead(14 + i));
      for (int i = 0; i < 5; i++) {
        Serial.print("Knap ");
        Serial.print(1 + i);
        Serial.print(" = ");
        Serial.println(analogRead(14 + i));
      }
      delay(200);
    }
  }

}

void pins() {
  pinMode(interruptPin, INPUT);      // Højre encoder
  pinMode(interruptPin2, INPUT);     // Venstre encoder
  pinMode(KNAP1_PIN, INPUT_PULLUP);  // Venstre trykknap
  pinMode(KNAP2_PIN, INPUT_PULLUP);  // midt-venstre trykknap
  pinMode(KNAP3_PIN, INPUT_PULLUP);  // midt trykknap
  pinMode(KNAP4_PIN, INPUT_PULLUP);  // midt-højre trykknap
  pinMode(KNAP5_PIN, INPUT_PULLUP);  // Højre trykknap
}

void add() {
  count_left_encoder++;
}

void add2() {
  count_right_encoder++;
}

// https://components101.com/microcontrollers/arduino-uno
