const byte interruptPin = 2;                //Højre encoder
const byte interruptPin2 = 3;               //Venstre encoder
const byte STATUS_LED_PIN = 4;              //Status LED
const byte LEFT_MOTOR_FORWARD_PIN = 5;      //Venstre LED
const byte LEFT_MOTOR_BACKWARD_PIN = 6;     //Venstre LED
const byte RIGHT_MOTOR_FORWARD_PIN = 9;     //Højre LED
const byte RIGHT_MOTOR_BACKWARD_PIN = 10;   //Højre LED

long count_left_encoder = 0;
long count_right_encoder = 0;

#include "LED.h"
#include "motor.h"

motor left_motor(LEFT_MOTOR_FORWARD_PIN, LEFT_MOTOR_BACKWARD_PIN);
motor right_motor(RIGHT_MOTOR_FORWARD_PIN, RIGHT_MOTOR_BACKWARD_PIN);

LED status_led(STATUS_LED_PIN);

void setup() {
  Serial.begin(9600);

  attachInterrupt(digitalPinToInterrupt(interruptPin), add, CHANGE);
  attachInterrupt(digitalPinToInterrupt(interruptPin2), add2, CHANGE);
}

void loop() {

  left_motor.backward(255);
  right_motor.backward(255);
  status_led.off();
  delay(1000);

  left_motor.forward(255);
  right_motor.forward(255);
  status_led.on();
  delay(1000);

}

void pins() {
  pinMode(2, INPUT);    //Højre encoder
  pinMode(3, INPUT);    //Venstre encoder
  pinMode(A0, INPUT_PULLUP);  //Venstre trykknap
  pinMode(A1, INPUT_PULLUP);  //midt-venstre trykknap
  pinMode(A2, INPUT_PULLUP);  //midt trykknap
  pinMode(A3, INPUT_PULLUP);  //midt-højre trykknap
  pinMode(A4, INPUT_PULLUP);  //Højre trykknap
}

void add() {
  count_left_encoder++;
}

void add2() {
  count_right_encoder++;
}
