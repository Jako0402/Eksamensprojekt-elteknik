const byte interruptPin = 2;
volatile int count = 0; 

void setup() {
  Serial.begin(9600);
  attachInterrupt(digitalPinToInterrupt(interruptPin), add, CHANGE);
}

void loop() {
  Serial.println(count);
  delay(10);
}

void add() {
  count++;
}
