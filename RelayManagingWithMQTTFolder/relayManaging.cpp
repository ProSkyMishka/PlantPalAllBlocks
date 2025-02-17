#include <ESP8266WiFi.h>
#include <PubSubClient.h> // Для работы с MQTT

const int relay = 5;

#define MQTT_VERSION MQTT_VERSION_3_1_1 // Устанавливаем версию MQTT

String clientId = "ESP8266-Prozorskiy_rel"; // Уникальный ID клиента для MQTT
#define MQTT_ID "/ESP8266-Prozorskiy_rel/"
#define MQTT_RELAY "/ESP8266-Prozorskiy_rel/Prozorskiy/" // Топик для устройства
#define PUB_RELAY "/ESP8266-Prozorskiy_rel/Prozorskiy_relay/" // Топик для отправки состояния реле
#define MSG_BUFFER_SIZE 20

const char *Topic = MQTT_RELAY; // Топик для устройства

bool flag;                   // Переменная для хранения значений для двигателя
char m_msg_buffer[MSG_BUFFER_SIZE]; // Буфер для получения сообщений

// Данные Wi-Fi
// Если данные не заданы, запускается captive portal для их получения
const char* ssid = "";       // Если пусто, будем запрашивать данные через AP
const char* password = "";   // Если пусто, будем запрашивать данные через AP

const char *mqtt_server = "m6.wqtt.ru"; // Адрес MQTT-сервера
const char *mqtt_user   = "u_JUYKMG";    // Логин для MQTT (если требуется)
const char *mqtt_pass   = "MTUZgJW2";    // Пароль для MQTT (если требуется)

WiFiClient espClient;            // Объект для подключения к Wi-Fi
PubSubClient client(espClient);  // Объект для работы с MQTT

const char *p_payload; // Указатель на полученные данные
float got_float;     // Для преобразования данных в число с плавающей точкой
int32_t got_int;
int i;               // Счётчик для циклов

// Пин для LED (на ESP8266 встроенный светодиод обычно на GPIO2)
const int ledPin = 2; 

// Функция подключения к Wi-Fi в режиме станции
bool connectWiFi(const char* ssid, const char* password) {
  WiFi.mode(WIFI_STA); // Режим клиента
  WiFi.begin(ssid, password);

  int connectionTimeout = 60; // Тайм-аут подключения (секунд)
  pinMode(ledPin, OUTPUT);

  Serial.println("Waiting for Wi-Fi connection...");
  while (WiFi.status() != WL_CONNECTED && connectionTimeout > 0) {
    digitalWrite(ledPin, !digitalRead(ledPin)); // Мигание LED для индикации ожидания
    Serial.println(WiFi.status());
    delay(1000);
    connectionTimeout--;
  }

  if (WiFi.status() == WL_CONNECTED) {
    digitalWrite(ledPin, LOW); // LED выключен (active low)
    Serial.println("Connection successful!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    return true;
  } else {
    digitalWrite(ledPin, HIGH); // LED выключен
    Serial.println("Failed to connect to Wi-Fi");
    return false;
  }
}

// Обработка сообщений MQTT
void callback(char *topic, byte *payload, unsigned int length) {
  for (i = 0; i < (int)length; i++) {
    m_msg_buffer[i] = payload[i];
  }
  m_msg_buffer[i] = '\0'; // Завершаем строку
  p_payload = m_msg_buffer;
  got_float = atof(p_payload); // Преобразуем строку в число

  got_int = (int)got_float;
  if (got_int == 0) {
    digitalWrite(relay, HIGH); // Выключаем реле
  } else if (got_int == 1) {
    digitalWrite(relay, LOW);  // Включаем реле
  }
  snprintf(m_msg_buffer, MSG_BUFFER_SIZE, "%d", got_int);
  client.publish(PUB_RELAY, m_msg_buffer, true);
}

// Функция переподключения к MQTT
void reconnect() {
  while (!client.connected()) {
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass)) {
      client.subscribe(MQTT_RELAY);
    } else {
      delay(6000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(relay, OUTPUT);
  digitalWrite(relay, HIGH); // Выключаем реле

  // Если данные Wi-Fi не заданы, запускаем режим точки доступа для их получения
  if (strlen(ssid) == 0) {
    Serial.println("Wi-Fi credentials not set. Starting captive portal...");

    // Индикация: включаем LED на 3 секунды
    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, LOW); // LED включен (active low)
    delay(3000);
    digitalWrite(ledPin, HIGH); // LED выключен

    // Настраиваем точку доступа с заданными параметрами
    const char* apSSID = "Servo-Control";
    const char* apPassword = "PicoW-Servo";
    WiFi.mode(WIFI_AP);
    WiFi.softAP(apSSID, apPassword);
    IPAddress apIP = WiFi.softAPIP();
    Serial.print("AP IP address: ");
    Serial.println(apIP);

    // Запускаем веб-сервер для приема новых данных Wi-Fi
    WiFiServer server(80);
    server.begin();
    Serial.println("Waiting for Wi-Fi configuration...");

    String newSSID = "";
    String newPassword = "";
    while (true) {
      WiFiClient clientAP = server.available();
      if (clientAP) {
        Serial.println("Client connected for configuration.");
        String request = "";
        while (clientAP.connected() && !clientAP.available()) {
          delay(1);
        }
        while (clientAP.available()) {
          char c = clientAP.read();
          request += c;
        }
        Serial.println("Request:");
        Serial.println(request);

        int ssidIndex = request.indexOf("ssid=");
        int passIndex = request.indexOf("/password=");
        if (ssidIndex != -1 && passIndex != -1) {
          newSSID = request.substring(ssidIndex + 5, passIndex);
          int endIndex = request.indexOf(" ", passIndex + 10);
          if (endIndex == -1) {
            endIndex = request.length();
          }
          newPassword = request.substring(passIndex + 10, endIndex);
          newSSID.replace("%20", " ");
          Serial.print("Received SSID: ");
          Serial.println(newSSID);
          Serial.print("Received Password: ");
          Serial.println(newPassword);

          // Отправляем ответ клиенту
          clientAP.print("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n");
          clientAP.print("{\"id\":\"");
          clientAP.print(clientId);
          clientAP.print("\"}");
          delay(1);
          clientAP.stop();

          // Пробуем подключиться к указанной Wi-Fi сети
          if (newSSID.length() > 0) {
            if (connectWiFi(newSSID.c_str(), newPassword.c_str())) {
              // Отключаем режим точки доступа
              WiFi.softAPdisconnect(true);
              break; // Выходим из цикла конфигурации
            }
          }
        } else {
          clientAP.stop();
        }
      }
      delay(10);
    }
  } else {
    // Если данные заданы, подключаемся как клиент
    connectWiFi(ssid, password);
  }

  // Настраиваем MQTT после подключения к Wi-Fi
  client.setServer(mqtt_server, 17888);
  client.setCallback(callback);
}

void loop() {
  // Основной цикл программы
  if (!client.connected()) {
    reconnect();
    delay(1000);
  }
  client.loop();
}
