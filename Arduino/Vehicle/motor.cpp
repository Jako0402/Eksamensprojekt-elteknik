#include "arduino.h"
#include "motor.h"

motor::motor(byte forward_pin, byte backward_pin) {
  this->forward_pin = forward_pin;      //Variablen "forward_pin" i "private" bliver magen
  this->backward_pin = backward_pin;    //til denne variabel i "motor(... forward_pin ...)".
  pinMode(forward_pin, OUTPUT);         //Ligeledes for "backward_pin", at den sætter
  pinMode(backward_pin, OUTPUT);        //"private's" "backward_pin" lig "public's" "backward_pin".
}

void motor::forward(int vehicle_speed) {   //Hastigheden "vehicle_speed" kan have værdier mellem 0 og 255.
  analogWrite(backward_pin, 0);             //De digitale pins kan sende et "analogWrite".
  analogWrite(forward_pin, vehicle_speed);  //https://www.arduino.cc/reference/en/language/functions/analog-io/analogwrite/
}

void motor::backward(int vehicle_speed) {
  analogWrite(forward_pin, 0);
  analogWrite(backward_pin, vehicle_speed);
}

void motor::drive(int vehicle_speed) {
  if (vehicle_speed > 0 ) {
    backward(0);
    forward(vehicle_speed);
  }
  if (vehicle_speed < 0 ) {
    forward(0);
    backward(abs(vehicle_speed));
  }
  if (vehicle_speed == 0 ) {
    forward(0);
    backward(0);
  }
}
