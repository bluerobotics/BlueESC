#include <WProgram.h>

#define CURRENT_ADC A3
#define VBAT_ADC A6
#define TEMP_ADC A7

#define BLUE_LED 10
#define RED_LED 9

//#define BLINK_CURRENT
#define BLINK_VBAT
//#define BLINK_TEMP

void blinkBlue() {
  digitalWrite(BLUE_LED,LOW);
  delay(50);
  digitalWrite(BLUE_LED,HIGH);
  delay(300);
}

void blinkRed() {
  digitalWrite(RED_LED,HIGH);
  delay(50);
  digitalWrite(RED_LED,LOW);
  delay(300);
}

void wait() {
  delay(1000);
}

void blink() {
  int16_t value;
#ifdef BLINK_CURRENT
  value = analogRead(CURRENT_ADC);
#endif
#ifdef BLINK_VBAT
  value = analogRead(VBAT_ADC);
#endif
#ifdef BLINK_TEMP
  value = analogRead(TEMP_ADC);
#endif

  uint8_t hundreds = value/100;
  uint8_t tens = (value%100)/10;
  uint8_t units = value%10;

  for ( uint8_t i = 0 ; i < hundreds ; i++ ) {
    blinkBlue();
  }
  wait();
  for ( uint8_t i = 0 ; i < tens ; i++ ) {
    blinkRed();
  }
  wait();
  for ( uint8_t i = 0 ; i < units ; i++ ) {
    blinkBlue();
  }
}

void setup() {
  Serial.begin(9600);

  pinMode(CURRENT_ADC,INPUT);
  pinMode(VBAT_ADC,INPUT);
  pinMode(TEMP_ADC,INPUT);

  pinMode(BLUE_LED,OUTPUT);
  pinMode(RED_LED,OUTPUT);
  digitalWrite(BLUE_LED,HIGH);

  blinkBlue();
  blinkRed();
  blinkBlue();

  delay(2000);
}

void loop() {
  Serial.print(analogRead(CURRENT_ADC));Serial.print(" ");
  Serial.print(analogRead(VBAT_ADC));Serial.print(" ");
  Serial.print(analogRead(TEMP_ADC));Serial.println("");

  blink();

  delay(2000);
}