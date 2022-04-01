#include "arduino.h"

class motor {
  public:
    motor(byte forward_pin, byte backward_pin);
    void forward(int vehicle_speed);
    void backward(int vehicle_speed);
    void drive(int vehicle_speed);

  private:
    byte forward_pin;  byte backward_pin; 
};
