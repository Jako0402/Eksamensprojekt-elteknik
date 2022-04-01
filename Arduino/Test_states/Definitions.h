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

  int left_motor_speed = 0;    //hastigheden kan være
  int right_motor_speed = 0;   //mellem -255 og 255

  unsigned long last_touch = 0;   //sidste gang køretøjet havde kontakt til noget

  long speed_change = 0;    //sidste gang køretøjets højre hjul ændrede sin hastighed

  byte state = 0;   //Hvilket stadie køretøjet er i

  motor left_motor(LEFT_MOTOR_FORWARD_PIN, LEFT_MOTOR_BACKWARD_PIN);     // Styrer venstre motor
  motor right_motor(RIGHT_MOTOR_FORWARD_PIN, RIGHT_MOTOR_BACKWARD_PIN);  // Styrer højre motor

  LED status_led(STATUS_LED_PIN);  // Styrer status LED'en


void pins() {
  pinMode(interruptPin, INPUT);      // Højre encoder
  pinMode(interruptPin2, INPUT);     // Venstre encoder
  pinMode(KNAP1_PIN, INPUT_PULLUP);  // Venstre trykknap
  pinMode(KNAP2_PIN, INPUT_PULLUP);  // midt-venstre trykknap
  pinMode(KNAP3_PIN, INPUT_PULLUP);  // midt trykknap
  pinMode(KNAP4_PIN, INPUT_PULLUP);  // midt-højre trykknap
  pinMode(KNAP5_PIN, INPUT_PULLUP);  // Højre trykknap
}
