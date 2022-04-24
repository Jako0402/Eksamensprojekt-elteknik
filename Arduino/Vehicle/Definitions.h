#include <SPI.h>

#include "src/RF24/RF24.h"
#include "src/RF24/nRF24L01.h"
#include "src/RF24/printf.h"

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

RF24 radio(7, 8);  // CE, CSN - pins
const byte stationAddress[6] = "00001"; //Modtager data fra stationen gennem denne kanal
const byte vehicleAddress[6] = "00002"; //Sender data til stationen gennem denne kanal
String toSend;  //Data der sendes til hovedstationen
String lastRecived; //Pakken køretøjet modtager fra hovedstationen
int commandArr[5];  //Dataen køretøjet modtager fra hovedstationen - (NR ; xpos ; ypos ; rotation ; status)
int arrLenth; //Længden på dataen fra "commandArr"
int contactStatus = -1; //Fortæller køretøjets status.  Hvis -1    = ingen forhindring - klar til ny kommando
                                                      //Hvis 0     = ingen forhindring - kører endnu
                                                      //Hvis 1 - 5 = Forhindring opdaget - klar til ny kommando
                                                      
long count_left_encoder = 0;  // Tæller af venstre encoder
long count_right_encoder = 0; // Tæller af højre encoder

unsigned long left_motor_calibrator = 0;  //Tæller venstre encoder siden sidste hastighedsændring
unsigned long right_motor_calibrator = 0; //Tæller højre encoder siden sidste hastighedsændring

int vehicle_speed = 0;   //bestemmer hastigheden af køretøjet - kan være mellem -255 og 255
int right_motor_speed = 0;  //er den regulerende hastighed - kan være mellem -255 og 255

unsigned long last_speed_change = 0; //sidste gang køretøjets hastighed blev ændret

unsigned long speed_change = 0;  //sidste gang køretøjets højre hjul ændrede sin hastighed

unsigned long last_contact = 0; //sidste gang køretøjet ramte en mur/eller andet.

byte state = 0; //Køretøjets stadie

boolean begin_new_movement = true; //Bruges til at starte kørtøjet, når den skal ændre sin bevægelse

motor left_motor(LEFT_MOTOR_FORWARD_PIN, LEFT_MOTOR_BACKWARD_PIN);    // Styrer venstre motor
motor right_motor(RIGHT_MOTOR_FORWARD_PIN, RIGHT_MOTOR_BACKWARD_PIN); // Styrer højre motor

LED status_led(STATUS_LED_PIN); // Styrer status LED'en

float wheel_diameter = 6.88;                                                                    //Hjulets diameter = 6,88 cm
float wheel_circumference = PI * wheel_diameter;                                                //Hjulets omkreds = 21,61 cm
int encoder_measurements = 40;                                                                  //Antal målinger hjulet kan fortage på én omgang = 40
float measurement_length = (wheel_circumference / encoder_measurements);                        //Længden af én måling på hjulet = 0,5404 cm
int rotation_diameter = 26;                                                                     //diameteren af køretøjets bane = 26 cm
int rotation_radius = rotation_diameter / 2;                                                    //Længden mellem hjulene = 13 cm
float rotation_circumference = PI * rotation_diameter;                                          //Omkredsen køretøjet foretage sig, når den drejer rundt = 81,68 cm
float measurement_rotation = ((measurement_length / rotation_circumference) * 2 * PI);          //Radianer køretøjet roterer, når den kører én måling = 0,0416
float measurement_forward = sin(measurement_rotation) * rotation_radius;                        //Delta Y (hvor langt køretøjet kører frem på én måling) = 0,5402
float measurement_sideways = rotation_radius - (cos(measurement_rotation) * rotation_radius);   //Delta X (hvor langt køretøjet kører ind på én måling) = 0,0112

float vehicle_X = 0;      //Bilens X-position
float vehicle_Y = 0;      //Bilens Y-position
float vehicle_angle = 0;  //Bilens vinkel i sin plan - Målt i radianer

float target_X = 0; //punktets X-koordinat sendt af hovedstationen
float target_Y = 0; //punktets Y-koordinat sendt af hovedstationen

float point_found_X = 0;  //sidste fundet punkts x-koordinat
float point_found_Y = 0;  //sidste fundet punkts y-koordinat

int delta_X = 0;  //X-afstand til koordinatet
int delta_Y = 0;  //Y-afstand til koordinatet

float distance_to_point = 0; //afstand til punktet

void pins() {
  pinMode(interruptPin, INPUT);      // Højre encoder
  pinMode(interruptPin2, INPUT);     // Venstre encoder
  pinMode(KNAP1_PIN, INPUT_PULLUP);  // Venstre trykknap
  pinMode(KNAP2_PIN, INPUT_PULLUP);  // midt-venstre trykknap
  pinMode(KNAP3_PIN, INPUT_PULLUP);  // midt trykknap
  pinMode(KNAP4_PIN, INPUT_PULLUP);  // midt-højre trykknap
  pinMode(KNAP5_PIN, INPUT_PULLUP);  // Højre trykknap
}
