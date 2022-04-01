#include "arduino.h"

class motor {
  public:
    short vehicle_speed;
    motor(byte forward_pin, byte backward_pin);
    void forward(short vehicle_speed);
    void backward(short vehicle_speed);
    void drive(short vehicle_speed);

  private:
    byte forward_pin;  byte backward_pin; 
};
