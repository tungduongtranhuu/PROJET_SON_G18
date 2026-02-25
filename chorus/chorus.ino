#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

#include "chorus.h"

// ================= AUDIO OBJECTS =================

// Audio input từ Audio Shield
AudioInputI2S            audioInput;

// Faust DSP object
chorus        faust;

// Audio output
AudioOutputI2S           audioOutput;

// Control Audio Shield
AudioControlSGTL5000     audioShield;

// Audio connections
AudioConnection patchCord1(audioInput, 1, faust, 0);   // Line In Right → Faust
AudioConnection patchCord2(faust, 0, audioOutput, 0);  // Left out
AudioConnection patchCord3(faust, 0, audioOutput, 1);  // Right out

// ================= POTENTIOMETERS =================

const int potRate  = A0;
const int potDepth  = A2;

// ================= SETUP =================

void setup() {

  AudioMemory(40);

  audioShield.enable();
  audioShield.inputSelect(AUDIO_INPUT_LINEIN);
  audioShield.lineInLevel(12);   
  audioShield.volume(0.7);



  Serial.begin(9600);
}

// ================= LOOP =================

void loop() {

  float rateVal  = analogRead(potRate)  / 1023.0f;
  float depthVal   = analogRead(potDepth)   / 1023.0f;


  float rateMapped  = 0.1f + rateVal  * (10.0f - 0.1f);
  float depthMapped   = 0.0f + depthVal * (1.0f - 0.0f);

 
  faust.setParamValue("Rate", rateMapped);
  faust.setParamValue("Depth", depthMapped);

  delay(50);
}



