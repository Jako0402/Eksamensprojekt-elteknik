void testRadio() {
//Skriver og modtager data fra hovedstationen til seriel og aktiverer LED
  if (radio.available()) {
    char text[32] = {0};
    radio.read(&text, sizeof(text));  //Læser hvad hovedstationen sender, og sætter værdierne i arrayet "text"
    Serial.println(text);
    status_led.on();
    lastRecived = String(text);

//Modtager en ulæsbar pakke
    if (checkData(lastRecived) != 0) {
      Serial.println(checkData(lastRecived));
      status_led.off();
      Serial.println("FEJL I PAKKEN");

//Modtager en læsbar pakke
    } else {
      splitGoodPackage();
      handleCommand();
      state = 1;
    }
  }
}

void aim_at_point(int targetX, int targetY) { //Sigter efter punktet hovedstationen har sendt

  vehicle_speed = 100;
  right_motor_speed = 90;
  float slope = (1 / (sin(vehicle_angle))); // Laver en fiktiv hældning for bilens retning i dens koordinatsystem

  int x = targetX - vehicle_X;

  unsigned long aim_on_target;

  turn_right();

  while ((slope * x + vehicle_Y > targetY + 100) || (slope * x + vehicle_Y < targetY - 100)) {  // Køretøjet drejer rundt indtil den sigter efter punktet (+- 100 cm  y-aksen)
    slope = (1 / (sin(vehicle_angle)));
    turn_right();
    aim_on_target = millis();
    Serial.println("done");
  }
  vehicle_stop();

  while (millis() - aim_on_target < 250) {  //Venter 250 ms, for at køretøjet kan få lov at stoppe
    delayMicroseconds(1);
  }
  state = 2;
}

void find_point() { //Kører ligeud indtil køretøjet kører væk fra punktet eller en af kontakterne rammer noget. kører funktionen "testRadio" imens, for at kunne sende data for, hvor den er.
  vehicle_speed = 100;
  right_motor_speed = 90;
  drive_forward();
  testRadio();
  if (sqrt(((vehicle_X - target_X) * (vehicle_X - target_X)) + ((vehicle_Y - target_Y) * (vehicle_Y - target_Y)) > distance_to_point)) { //Hvis køretøjet kører væk fra punktet stopper den
    contactStatus = -1;
    state = 0;
  }

  delta_X = vehicle_X - target_X;
  delta_Y = vehicle_Y - target_Y;

  distance_to_point = sqrt((delta_X * delta_X) + (delta_Y * delta_Y));

  for (int i = 0; i < 5; i++) {   //Hvis en kontakt rammer noget
    byte noiseCount = 0;
    while (digitalRead(14 + i) && noiseCount < 20) {      //En knap skal være 'aktiv' 20 gange
      noiseCount++;
    }
    if (noiseCount > 5) {
      Serial.print("Knap ");
      Serial.println(i + 1);
<<<<<<< HEAD
      noiseCount = 0;
      last_contact = millis();
      contactStatus = i;
      point_found_X = vehicle_X;
      point_found_Y = vehicle_Y;
      state = 3;  //Der er fundet et punkt
=======
      switch (state) {  //Skifter til stadiet "point_found"
        case 0:
          state = 1;
          break;
      }
    }
  }
  if (digitalRead(18)) {
    switch (state) {  //Skifter til stadiet "stop"
      case 0:
        state = 112;
        break;

>>>>>>> 0d550c0fe372b87b111f5b5208a754098cdbc280
    }
  }
}

void point_found() {
  vehicle_speed = 100;
  right_motor_speed = 90;

<<<<<<< HEAD
  if (millis() - last_contact < 1000) {   //bakker i 1 sekund, for derefter at stoppe
    drive_backward();
  } else {
    vehicle_stop();
=======
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
      case 112:       //til
        state = 0;    //stadiet
        left_motor.drive(left_motor_speed);
        right_motor.drive(right_motor_speed);
        break;        //"find_point"
    }
>>>>>>> 0d550c0fe372b87b111f5b5208a754098cdbc280
  }

  state = 0;  //venter på at den får et nyt punkt at sigte efter.

}
