
void find_point() {
  for (int i = 0; i < 4; i++) {
    byte noiseCount = 0;
    while (digitalRead(14 + i) && noiseCount < 20) {      //En knap skal være 'aktiv' 20 gange - 1 gang er
      noiseCount++;
    }
    if (noiseCount > 5) {
      last_touch = millis();
      Serial.print("Knap ");
      Serial.println(i + 1);
      switch (state) {  //Skifter
        case 0:         //til
          state = 1;    //stadiet
          break;        //"point_found"
      }
    }
  }
  if (digitalRead(18)) {
    switch (state) {  //Skifter
      case 0:         //til
        state = 112;  //stadiet
        break;        //"stop"
    }
  }
}

void get_point() {
  left_motor.drive(0);
  right_motor.drive(0);
  delay(250);
  left_motor.drive(-left_motor_speed);
  right_motor.drive(-right_motor_speed);
  delay(100);

  switch (state) {  //Skifter
    case 1:         //til
      state = 0;    //stadiet
      left_motor.drive(left_motor_speed);
      right_motor.drive(right_motor_speed);
      break;        //"find_point"
  }
}

void stop_ () {

  left_motor.drive(0);
  right_motor.drive(0);

  if (digitalRead(14)) {
    switch (state) {  //Skifter
      case 112:         //til
        state = 0;    //stadiet
        left_motor.drive(left_motor_speed);
        right_motor.drive(right_motor_speed);
        break;        //"find_point"
    }
  }
}
