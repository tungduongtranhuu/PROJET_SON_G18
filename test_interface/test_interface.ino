void setup() {
  Serial.begin(115200);
  pinMode(13, OUTPUT);
  analogWriteResolution(8);
}

void loop() {
  if (Serial.available()) {
    String cmd = Serial.readStringUntil('\n');
    if (cmd.startsWith("LED=")) {
      float val = cmd.substring(4).toFloat();
      if (val < 0.0) val = 0.0;
      if (val > 0.5) val = 1.0;

      int pwm = val * 255.0;
      analogWrite(13, pwm);
    }
  }
}