#include "arduino.h"

class motor {
  public:
    byte vehicle_speed;
    motor(byte forward_pin, byte backward_pin);
    void forward(byte vehicle_speed);
    void backward(byte vehicle_speed);

  private:
    byte forward_pin;  byte backward_pin;
};
