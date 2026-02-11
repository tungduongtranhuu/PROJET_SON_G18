#include <Audio.h>
#include <Wire.h>
#include <SPI.h>

// Objets audio
AudioInputI2S        i2s1;      // Entrée Line In (L + R)
AudioOutputUSB       usb1;      // Pour tester sur PC
AudioConnection      patchCord1(i2s1, 1, usb1, 1); // canal R
AudioControlSGTL5000 sgtl5000;

void setup() {
  AudioMemory(12);

  sgtl5000.enable();
  sgtl5000.inputSelect(AUDIO_INPUT_LINEIN);
  sgtl5000.lineInLevel(5);  
}

void loop() {
}