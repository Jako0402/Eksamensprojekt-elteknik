
int start = 1000;
int drive = 1000;
int pause = 1000;


void driveProgram() {
  encodersValue();
  
  for (int i = 0; i < start / 2; i++) {
    digitalWrite(5, HIGH);
    digitalWrite(9, HIGH);
    delay(1);
    digitalWrite(5, LOW);
    digitalWrite(9, LOW);
    delay(1);
  }

  encodersValue();

  digitalWrite(5, HIGH);
  digitalWrite(9, HIGH);

  delay(drive);

  encodersValue();

  digitalWrite(5, LOW);
  digitalWrite(9, LOW);

  delay(pause);

  encodersValue();

  for (int i = 0; i < start / 2; i++) {
    digitalWrite(6, HIGH);
    digitalWrite(10, HIGH);
    delay(1);
    digitalWrite(6, LOW);
    digitalWrite(10, LOW);
    delay(1);
  }

  encodersValue();

  digitalWrite(6, HIGH);
  digitalWrite(10, HIGH);

  delay(drive);

  encodersValue();

  digitalWrite(6, LOW);
  digitalWrite(10, LOW);

  delay(pause);
}

void  encodersValue() {
  Serial.print("Højre hjul ");
  Serial.print(countRightEncoder);
  Serial.print("   Venstre hjul ");
  Serial.println(countLeftEncoder);
}
