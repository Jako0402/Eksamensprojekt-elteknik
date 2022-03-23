const byte interruptPin = 2;
const byte interruptPin2 = 3;

//Her er noget mere kode

volatile int count = 0; 
volatile int count2 = 0; 

void setup() {
  Serial.begin(9600);
  attachInterrupt(digitalPinToInterrupt(interruptPin), add, CHANGE);
  attachInterrupt(digitalPinToInterrupt(interruptPin2), add, CHANGE);
}

void loop() {
  Serial.println(count);
  delay(10);
}

void add() {
  count++;
}
