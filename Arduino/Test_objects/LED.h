#include "arduino.h"

class LED {
  public:
    LED(byte pin);
    void on();
    void off();
  private:
    byte pin;
};
