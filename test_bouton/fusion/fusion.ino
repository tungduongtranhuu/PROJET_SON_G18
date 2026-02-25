#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

#include "fusion.h"

// ================= AUDIO OBJECTS =================

// Audio input từ Audio Shield
AudioInputI2S            audioInput;

// Faust DSP object
fusion        faust;

// Audio output
AudioOutputI2S           audioOutput;

// Control Audio Shield
AudioControlSGTL5000     audioShield;

// Mixer
AudioMixer4 mixer;

// Audio connections
AudioConnection patchCord1(audioInput, 1, faust, 0);
AudioConnection patchCord2(faust, 0, mixer, 0);
AudioConnection patchCord3(audioInput, 1, mixer, 1);
AudioConnection patchCord4(mixer, 0, audioOutput, 0);
AudioConnection patchCord5(mixer, 0, audioOutput, 1);

// Variables
float volumeVal = 1.0;
float durationVal = 0.1;
float feedbackVal = 0.4;
float driveVal = 1;
float toneVal = 1500;

int pinButton = 2;
int effectActive = 0; // Not active
bool lastState = LOW;

// ================= SETUP =================

void setup() {
  pinMode(pinButton, INPUT_PULLUP); // digital pin 0 is an input

  AudioMemory(40);

  audioShield.enable();
  audioShield.inputSelect(AUDIO_INPUT_LINEIN);
  audioShield.lineInLevel(12);   // chỉnh gain input nếu cần
  audioShield.volume(0.7);
  mixer.gain(0, 0.0); // effet
  mixer.gain(1, 1.0); // dry

  faust.setParamValue("Drive", driveVal);
  faust.setParamValue("Tone", toneVal);
  faust.setParamValue("Volume", volumeVal);
  faust.setParamValue("duration", durationVal);
  faust.setParamValue("feedback coef", feedbackVal);

  Serial.begin(9600);
}

// ================= LOOP =================

void loop() {
  if ((digitalRead(pinButton) == HIGH) and (lastState == LOW)) { // if button is pressed
    effectActive = (effectActive + 1)%2;
    //Serial.println("Button");
    //Serial.println(digitalRead(pinButton));
    lastState = HIGH;
  }
  //else if (digitalRead(pinButton) == LOW) {Serial.println("No"); Serial.println(digitalRead(pinButton));}

  if ((digitalRead(pinButton) == LOW) and (lastState == HIGH)) {
    lastState = LOW;
  }

  if (effectActive) {
    mixer.gain(0, 1.0); // effet ON
    mixer.gain(1, 0.0);
  }
  else {
      mixer.gain(0, 0.0); // bypass
      mixer.gain(1, 1.0);
  }

  delay(50);
}