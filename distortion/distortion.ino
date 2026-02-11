#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

#include "distortion.h"

// =======================
// FAUST DSP
// =======================
distortion dsp;

// =======================
// AUDIO OBJECTS
// =======================
AudioInputI2S        i2s_in;
AudioOutputI2S       i2s_out;
AudioControlSGTL5000 sgtl5000_1;

// =======================
// AUDIO CONNECTIONS
// =======================
AudioConnection patchCord1(i2s_in, 1, dsp, 0);   // LINE IN L -> DSP
AudioConnection patchCord2(dsp, 0, i2s_out, 0);  // DSP -> OUT L
AudioConnection patchCord3(dsp, 0, i2s_out, 1);  // DSP -> OUT R

// =======================
// POTENTIOMETERS
// =======================
const int potDrive = A2;
const int potTone  = A0;

void setup() {

  Serial.begin(9600);

  AudioMemory(120);

  // =======================
  // AUDIO SHIELD SETUP
  // =======================
  sgtl5000_1.enable();
  sgtl5000_1.inputSelect(AUDIO_INPUT_LINEIN);
  sgtl5000_1.lineInLevel(12);   // thử 10–15 nếu tiếng nhỏ
  sgtl5000_1.volume(0.3);

  // Tăng độ phân giải ADC cho pot
  analogReadResolution(12);  // 0–4095

}

void loop() {

  // =======================
  // READ POTS
  // =======================
  int driveVal = analogRead(potDrive);
  int toneVal  = analogRead(potTone);

  // =======================
  // MAP VALUES
  // =======================
  float driveMapped = 1.0 + (driveVal / 4095.0) * 39.0;     // 1 → 40
  float toneMapped  = 800.0 + (toneVal / 4095.0) * 5200.0;  // 800 → 6000 Hz

  // =======================
  // UPDATE DSP SAFELY
  // =======================
  AudioNoInterrupts();
  dsp.setParamValue("Drive", driveMapped);
  dsp.setParamValue("Tone", toneMapped);
  AudioInterrupts();

  delayMicroseconds(500);
}
