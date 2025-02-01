#include <WiFi.h>
#include <WiFiManager.h>
#include <Firebase_ESP_Client.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// Firebase credentials
#define FIREBASE_HOST "https://frostfresh-7de8e-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_API_KEY "AIzaSyCngMKmeOiCCKomLoPXbVW_SVEi0sQeUIA"

// DS18B20 Temperature Sensor Configuration
#define ONE_WIRE_BUS 4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// MQ-2 Ethylene Sensor Configuration
#define MQ2_SENSOR_PIN 35 // GPIO pin for MQ-2 sensor

// Relay Configuration
#define RELAY_PIN 2
bool relayState = false;

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Status flag for Firebase sign-up or initialization
bool signUpOK = false;

// Function to read temperature from DS18B20
float readTemperature() {
  sensors.requestTemperatures();
  float temperature = sensors.getTempFByIndex(0);
  if (temperature == DEVICE_DISCONNECTED_C) {
    Serial.println("Error: Could not read temperature!");
    return 0.0;
  }
  return temperature;
}

// Function to read ethylene level from MQ-2
float readEthylene() {
  int sensorValue = analogRead(MQ2_SENSOR_PIN);
  // Adjust the sensitivity calculation based on calibration
  float ethylenePPM = (sensorValue / 4095.0) * 100.0; 
  
  // Apply calibration factor (adjust based on your calibration)
  float calibrationFactor = 1.2; // Example calibration factor
  ethylenePPM *= calibrationFactor;

  return ethylenePPM;
}

// Function to control relay based on temperature
void controlRelay(float temperature) {
  if (temperature > 43.0 && !relayState) {
    digitalWrite(RELAY_PIN, LOW); // Turn relay ON
    relayState = true;
    Serial.println("Relay ON: Temperature exceeded 43°F");
  } else if (temperature < 35.0 && relayState) {
    digitalWrite(RELAY_PIN, HIGH); // Turn relay OFF
    relayState = false;
    Serial.println("Relay OFF: Temperature dropped below 35°F");
  }
}

// Function to send sensor data to Firebase
void sendDataToFirebase(float temperature, float ethylene) {
  if (!signUpOK) {
    Serial.println("Firebase not ready. Skipping data upload...");
    return;
  }

  // Send temperature to Firebase
  if (Firebase.RTDB.setFloat(&fbdo, "/temperature", temperature)) {
    Serial.println("Temperature sent: " + String(temperature) + "°F");
  } else {
    Serial.println("Failed to send temperature: " + fbdo.errorReason());
  }

  // Send ethylene level to Firebase
  if (Firebase.RTDB.setFloat(&fbdo, "/ethylene", ethylene)) {
    Serial.println("Ethylene level sent: " + String(ethylene) + " PPM");
  } else {
    Serial.println("Failed to send ethylene level: " + fbdo.errorReason());
  }

  // Send relay state to Firebase
  if (Firebase.RTDB.setBool(&fbdo, "/relayState", relayState)) {
    Serial.println("Relay state sent: " + String(relayState ? "ON" : "OFF"));
  } else {
    Serial.println("Failed to send relay state: " + fbdo.errorReason());
  }
}

void setup() {
  Serial.begin(115200);

  // WiFiManager setup
  WiFiManager wifiManager;

  // AutoConnect will try to connect to saved credentials or create a portal
  if (!wifiManager.autoConnect("ESP32-Config-Portal")) {
    Serial.println("Failed to connect to Wi-Fi, restarting...");
    ESP.restart();
  }

  Serial.println("Connected to Wi-Fi");
  Serial.println("IP Address: " + WiFi.localIP().toString());

  // Firebase configuration
  config.api_key = FIREBASE_API_KEY;
  config.database_url = FIREBASE_HOST;

  // Initialize Firebase with both config and auth
  Firebase.begin(&config, &auth);

  Serial.println("Signing in anonymously...");
  if (Firebase.signUp(&config, &auth, "", "")) {
    signUpOK = true; // Set flag to true if Firebase initializes successfully
    Serial.println("Firebase initialized successfully");
  } else {
    signUpOK = false; // Set flag to false if Firebase fails to initialize
    Serial.println("Failed to initialize Firebase");
    Serial.println("Error: " + String(config.signer.signupError.message.c_str()));
  }

  // Initialize DS18B20 sensor
  sensors.begin();

  // Initialize relay pin
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW); // Ensure relay starts in the OFF state
}

void loop() {
  // Read data from sensors
  float temperature = readTemperature();
  float ethylene = readEthylene();

  // Log sensor data to Serial Monitor
  Serial.println("Temperature: " + String(temperature) + "°F");
  Serial.println("Ethylene Level: " + String(ethylene) + " PPM");

  // Control the relay based on temperature
  controlRelay(temperature);

  // Send data to Firebase
  sendDataToFirebase(temperature, ethylene);

  delay(2000); // Delay between sensor readings
}
