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

// Variables
float volumeVal = 0.0;
float durationVal = 0.0;
float feedbackVal = 0.0;
float driveVal = 0.0;
float toneVal = 0.0;

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
  // Get values from interface
  if (Serial.available()) {
    String cmd = Serial.readStringUntil('\n');

    int parsed = sscanf(cmd.c_str(), "%f,%f,%f,%f,%f",
                        &volumeVal, &durationVal, &feedbackVal,
                        &driveVal, &toneVal);

    if (parsed == 5) {
      int pwm = volumeVal * 255.0;
      analogWrite(13, pwm);

      // Debug
      Serial.println("Received:");
      Serial.println(volumeVal);
      Serial.println(durationVal);
      Serial.println(feedbackVal);
      Serial.println(driveVal);
      Serial.println(toneVal);
    }
  }

  // Set parameters theo đúng tên trong Faust UI
  faust.setParamValue("Drive", driveVal);
  faust.setParamValue("Tone", toneVal);
  faust.setParamValue("Volume", volumeVal);
  faust.setParamValue("duration", durationVal);
  faust.setParamValue("feedback coef", feedbackVal);

  delay(50);
}