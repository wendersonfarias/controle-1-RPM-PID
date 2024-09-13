#include <PID_v1.h>

const int pwmPin = 25;
const int pino_sensor = 34;  

const int helices = 9;             // Número de hélices do cooler
volatile int mudancas_estado = 0;  // Variável que será usada na interrupção

unsigned long tempo_inicial = 0;  // Para armazenar o tempo inicial
unsigned long tempo_serial = 0;   // Para armazenar o tempo plotar serial
unsigned long intervalo = 1000;   // Intervalo de 1 segundo (em milissegundos)
int valorSetPoint = 300;

volatile float rpm;

//PID
double SetPoint, Input, Output = 10;

double KP = 0.4, KI = 0.3, KD = 0;

PID myPID(&Input, &Output, &SetPoint, KP, KI, KD, DIRECT);


  // Função chamada na interrupção (conta transições de 1 para 0)
  void contarTransicoes() {
    if (digitalRead(pino_sensor) == LOW) {  // Detecta transição de 1 para 0
      mudancas_estado++;
    }
  }

void setup() {


  Serial.begin(115200);
  analogReadResolution(10);

  //RANGE ENTRE OS VALORES DE SAIDA
  myPID.SetMode(AUTOMATIC);
  //myPID.SetOutputLimits(0, 1023);
  myPID.SetSampleTime(50);
  SetPoint = 100;

  //CONFIGURAÇÃO DE PWM
  ledcSetup(0, 1000, 8);
  ledcAttachPin(25, 0);

  //DEFINE PINO DE LEITURA DO POTENCIOMETRO
  pinMode(pino_sensor, INPUT);  // Configura o pino como entrada

  //delay(3000);

  //DEFINE UMA INTERUÇÃO DE BORDA DE DESCIDA
  attachInterrupt(digitalPinToInterrupt(pino_sensor), contarTransicoes, FALLING);  // Configura interrupção
  tempo_inicial = millis();                                                        // Armazena o tempo inicial
}

void loop() {
  if (Serial.available() > 0) {
    int recebido = Serial.parseInt();
    if (recebido > 0 && recebido <= 1023) { // Verifique se o valor está dentro do intervalo esperado
        if(recebido == 0){
          Serial.println(recebido);
        }
        valorSetPoint = recebido;
        //Serial.println(recebido);
    }

    
}

  // Verifica se já se passou 1 segundo
  if (millis() - tempo_inicial >= 100) {
    // Calcula o RPM
    float rotacoes_por_segundo = (float)mudancas_estado / helices;  // Número de rotações completas por segundo
    rpm = rotacoes_por_segundo * 60 * 10 ;                    // Converte para rotações por minuto

    // Reseta o contador e o tempo
    mudancas_estado = 0;
    tempo_inicial = millis();  // Atualiza o tempo inicial
  }

  Input = rpm ;

  SetPoint = valorSetPoint;

  
  myPID.Compute();
  ledcWrite(0, Output);  // Aplica o valor ao PWM
  


  if (millis() - tempo_serial > 100){

    tempo_serial = millis();
    Serial.print(SetPoint);
    Serial.print(" ");
    Serial.print(Input);
    Serial.print(" ");
    Serial.print(Output);
    Serial.println(" ");

    
  }

}