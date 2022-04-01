#include "arduino.h"
#include "LED.h"

LED::LED(byte pin) {
  this-> pin = pin;
  pinMode(pin, OUTPUT);
}

void LED::on() {
  digitalWrite(pin, HIGH);
}

void LED::off() {
  digitalWrite(pin, LOW);
}
