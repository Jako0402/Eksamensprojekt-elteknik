
int interruptPin = 2;
int interruptPin2 = 3;

int countRightEncoder = 0;
int countLeftEncoder = 0;

int serialTime = 100;

void setup() {

  pins();

  Serial.begin(9600);
  attachInterrupt(digitalPinToInterrupt(interruptPin), add, CHANGE);
  attachInterrupt(digitalPinToInterrupt(interruptPin2), add2, CHANGE);

}

void loop() {

driveProgram;

}

void pins() {
  pinMode(2, INPUT);    //Højre encoder
  pinMode(3, INPUT);    //Venstre encoder
  pinMode(4, OUTPUT);         //Status LED
  pinMode(5, OUTPUT);   //Venstre hjul  -  De blev bevidst sat på disse porte for at kunne
  pinMode(6, OUTPUT);   //Venstre hjul  -  lave funktionen "analogWrite()".
  pinMode(9, OUTPUT);   //Højre hjul    -  https://www.arduino.cc/reference/en/language/functions/analog-io/analogwrite/
  pinMode(10, OUTPUT);  //Højre hjul    -  Disse pins hedder "PWM" outputs
  pinMode(A0, INPUT_PULLUP);  //Venstre trykknap
  pinMode(A1, INPUT_PULLUP);  //midt-venstre trykknap
  pinMode(A2, INPUT_PULLUP);  //midt trykknap
  pinMode(A3, INPUT_PULLUP);  //midt-højre trykknap
  pinMode(A4, INPUT_PULLUP);  //Højre trykknap
}

void add() {
  countRightEncoder++;
}

void add2() {
  countLeftEncoder++;
}
