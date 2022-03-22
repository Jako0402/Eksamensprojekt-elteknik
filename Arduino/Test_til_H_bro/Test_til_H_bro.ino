
int start = 1000;
int kor = 1000;
int pause = 1000;

void setup() {

  pinMode(5, OUTPUT);   //Venstre hjul
  pinMode(6, OUTPUT);   //Venstre hjul
  pinMode(9, OUTPUT);   //Højre hjul
  pinMode(10, OUTPUT);   //Højre hjul

  Serial.begin(9600);

}

void loop() {

  for (int i = 0; i < start / 2; i++) {
    digitalWrite(5, HIGH);
    digitalWrite(9, HIGH);
    delay(1);
    digitalWrite(5, LOW);
    digitalWrite(9, LOW);
    delay(1);
  }
  Serial.println("Start Frem");

  digitalWrite(5, HIGH);
  digitalWrite(9, HIGH);
  Serial.println("Frem");

  delay(kor);

  digitalWrite(5, LOW);
  digitalWrite(9, LOW);
  Serial.println("Pause");

  delay(pause);

  for (int i = 0; i < start / 2; i++) {
    digitalWrite(5, HIGH);
    digitalWrite(9, HIGH);
    delay(1);
    digitalWrite(5, LOW);
    digitalWrite(9, LOW);
    delay(1);
  }
  Serial.println()
  
  digitalWrite(6, HIGH);
  digitalWrite(10, HIGH);
  Serial.println("Tilbage");

  delay(kor);

  digitalWrite(6, LOW);
  digitalWrite(10, LOW);
  Serial.println("Pause");

  delay(pause);
}
