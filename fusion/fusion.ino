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

// Audio connections
AudioConnection patchCord1(audioInput, 1, faust, 0);   // Line In Right → Faust
AudioConnection patchCord2(faust, 0, audioOutput, 0);  // Left out
AudioConnection patchCord3(faust, 0, audioOutput, 1);  // Right out

// ================= POTENTIOMETERS =================

const int potDrive  = A1;
const int potTone   = A2;
const int potVolume = A0;
const int potDuration = A3;
const int potFeedback  = A8;

// ================= SETUP =================

void setup() {

  AudioMemory(40);

  audioShield.enable();
  audioShield.inputSelect(AUDIO_INPUT_LINEIN);
  audioShield.lineInLevel(12);   // chỉnh gain input nếu cần
  audioShield.volume(0.7);



  Serial.begin(9600);
}

// ================= LOOP =================

void loop() {

  // Đọc potentiometer (0–1023)
  float driveVal  = analogRead(potDrive)  / 1023.0f;
  float toneVal   = analogRead(potTone)   / 1023.0f;
  float volumeVal = analogRead(potVolume) / 1023.0f;
  float durationVal = analogRead(potDuration);
  float feedbackVal  = analogRead(potFeedback);

  // Map về đúng range như trong Faust
  float driveMapped  = 1.0f  + driveVal  * (50.0f - 1.0f);
  float toneMapped   = 1500.0f + toneVal * (8000.0f - 1500.0f);
  float volumeMapped = volumeVal; // 0–1
  float durationMapped = (durationVal / 4095.0) * 3.0;     // 0 → 3
  float feedbackMapped = feedbackVal / 4095.0;           // 0 → 1

  // Set parameters theo đúng tên trong Faust UI
  faust.setParamValue("Drive", driveMapped);
  faust.setParamValue("Tone", toneMapped);
  faust.setParamValue("Volume", volumeMapped);
  faust.setParamValue("duration", durationMapped);
  faust.setParamValue("feedback coef", feedbackMapped);

  delay(50);
}