#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

#include "echo.h"

// =======================
// ====== FAUST DSP ======
// =======================
echo dsp;

// =======================
// ==== AUDIO OBJECTS ====
// =======================
AudioInputI2S        i2s_in;
AudioOutputI2S       i2s_out;
AudioControlSGTL5000 sgtl5000_1;

// =======================
// == AUDIO CONNECTIONS ==
// =======================
AudioConnection patchCord1(i2s_in, 1, dsp, 0);
AudioConnection patchCord2(dsp, 0, i2s_out, 0);
AudioConnection patchCord3(dsp, 0, i2s_out, 1);

// =======================
// ==== POTENTIOMETERS ===
// =======================
const int potDuration = A2;
const int potFeedback  = A0;
const int potGain = A3;

void setup() {

  Serial.begin(9600);

  AudioMemory(120);

  // =======================
  // == AUDIO SHIELD SETUP =
  // =======================
  sgtl5000_1.enable();
  sgtl5000_1.inputSelect(AUDIO_INPUT_LINEIN);
  sgtl5000_1.lineInLevel(12); 
  sgtl5000_1.volume(0.4);

  analogReadResolution(12);  

}

void loop() {

  // =======================
  // ====== READ POTS ======
  // =======================
  int durationVal = analogRead(potDuration);
  int feedbackVal  = analogRead(potFeedback);
  int gainVal = analogRead(potGain);

  // =======================
  // ====== MAP VALUES =====
  // =======================
  float durationMapped = (durationVal / 4095.0) * 3.0;     // 0 → 3
  float feedbackMapped = feedbackVal / 4095.0;           // 0 → 1
  float gainMapped = (gainVal / 4095.0) * 7.0;

  // =======================
  // == UPDATE DSP SAFELY ==
  // =======================
  AudioNoInterrupts();
  dsp.setParamValue("duration", durationMapped);
  dsp.setParamValue("feedback coef", feedbackMapped);
  dsp.setParamValue("gain", gainMapped);
  AudioInterrupts();

  delayMicroseconds(500);
}