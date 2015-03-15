
#define LED_PIN 13
void setup() {
  // put your setup code here, to run once:
  pinMode(LED_PIN, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  
  while (Serial.available()){
  
    char incomingChar = Serial.read();
    if (incomingChar != '0') {
      digitalWrite(LED_PIN, HIGH);
    }
    else {
      digitalWrite(LED_PIN, LOW);
    }
    
    delay(500);
  
  }
  
  

}
