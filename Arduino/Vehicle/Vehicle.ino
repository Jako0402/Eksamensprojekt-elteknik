const byte interruptPin2 = 2;              // Højre encoder
const byte interruptPin = 3;               // Venstre encoder
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

int left_motor_speed = 120;    //hastigheden kan være
int right_motor_speed = 80;   //mellem -255 og 255

unsigned long last_touch = 0;

#include "LED.h"
#include "motor.h"

motor left_motor(LEFT_MOTOR_FORWARD_PIN, LEFT_MOTOR_BACKWARD_PIN);     // Styre venstre motor
motor right_motor(RIGHT_MOTOR_FORWARD_PIN, RIGHT_MOTOR_BACKWARD_PIN);  // Styre højre motor

LED status_led(STATUS_LED_PIN);  // Styre status LED'en

long speed_change = 0;

void setup() {
  pins();

  Serial.begin(9600);

  attachInterrupt(digitalPinToInterrupt(interruptPin), add, CHANGE);      // Tæller encoderen for venstre hjul
  attachInterrupt(digitalPinToInterrupt(interruptPin2), add2, CHANGE);    // Tæller encoderen for højre hjul

  left_motor.drive(left_motor_speed);
  right_motor.drive(right_motor_speed);

  while (millis() < 3000);
}

void loop() {


  if ((millis() - last_touch) > 3000) {   //Der skal være gået 3 sekundt siden vi ramte muren, før vi måler igen
    for (int i = 0; i < 5; i++) {
      byte noiseCount = 0;
      while (digitalRead(14 + i) && noiseCount < 20) {      //En knap skal være 'aktiv' 20 gange - 1 gang er
        noiseCount++;
      }
      if (noiseCount > 5) {
        last_touch = millis();
        left_motor_speed = left_motor_speed * -1;
        right_motor_speed = right_motor_speed * -1;
        Serial.print("Knap ");
        Serial.println(i + 1);
        if (14 + i == 18) {       //Knap 5 slukker motorerne
          left_motor_speed = 0;
          right_motor_speed = 0;
        }
        left_motor.drive(left_motor_speed);
        right_motor.drive(right_motor_speed);
      }
    }
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
