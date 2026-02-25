void setup() {
  Serial.begin(115200);
  pinMode(13, OUTPUT);
  analogWriteResolution(8);
}

void loop() {
  if (Serial.available()) {
    String cmd = Serial.readStringUntil('\n');

    float volume, duration, feedback, drive, tone;

    int parsed = sscanf(cmd.c_str(), "%f,%f,%f,%f,%f",
                        &volume, &duration, &feedback,
                        &drive, &tone);

    if (parsed == 5) {
      int pwm = volume * 255.0;
      analogWrite(13, pwm);

      // Debug
      Serial.println("Received:");
      Serial.println(volume);
      Serial.println(duration);
      Serial.println(feedback);
      Serial.println(drive);
      Serial.println(tone);
    }
  }
}