import processing.serial.*;

Serial myPort;          // Objeto da serial
String serialData = "";  // String para armazenar os dados da serial

int setpoint = 0;        // Variável para armazenar o valor do setpoint
int rpm = 0;             // Variável para armazenar o valor do RPM
int mediaPwm = 0;        // Variável para armazenar o valor da média do PWM
int valorParaEnviar = 0; // Valor que será enviado para o ESP32

String inputText = "";   // Armazena o texto digitado para envio

void setup() {
  size(600, 400);
  
  // Inicializando a comunicação serial (ajuste a porta serial)
  String portName = Serial.list()[0]; // Lista de portas, ajuste conforme necessário
  myPort = new Serial(this, portName, 9600);
  
  // Configuração inicial
  myPort.bufferUntil('\n');  // Espera até receber uma nova linha
}

void draw() {
  background(255);
  
  // Exibe os gráficos
  drawGraph();
  
  // Exibe os valores lidos da serial em caixas de texto
  drawTextBoxes();
  
  // Caixa de entrada de texto para enviar dados
  drawInputBox();
  
  // Enviar o valor digitado
  if (keyPressed && key == ENTER) {
    enviarValor();
  }
}

// Função que desenha os gráficos com base nos valores recebidos
void drawGraph() {
  stroke(0);
  fill(200, 200, 255);
  
  // Desenhar o gráfico para setpoint
  rect(50, 150, setpoint, 30);  // Desenha um retângulo proporcional ao valor
  fill(0);
  text("Setpoint: " + setpoint, 50, 145);
  
  // Desenhar o gráfico para RPM
  fill(200, 255, 200);
  rect(50, 200, rpm, 30);
  fill(0);
  text("RPM: " + rpm, 50, 195);
  
  // Desenhar o gráfico para Media PWM
  fill(255, 200, 200);
  rect(50, 250, mediaPwm, 30);
  fill(0);
  text("Média PWM: " + mediaPwm, 50, 245);
}

// Função para desenhar caixas de texto para exibir os valores
void drawTextBoxes() {
  fill(255);
  stroke(0);
  
  // Caixa de texto para Setpoint
  rect(350, 100, 150, 30);
  fill(0);
  text("Setpoint: " + setpoint, 360, 120);
  
  // Caixa de texto para RPM
  fill(255);
  rect(350, 150, 150, 30);
  fill(0);
  text("RPM: " + rpm, 360, 170);
  
  // Caixa de texto para Média PWM
  fill(255);
  rect(350, 200, 150, 30);
  fill(0);
  text("Média PWM: " + mediaPwm, 360, 220);
}

// Função para desenhar a caixa de entrada de texto
void drawInputBox() {
  fill(255);
  rect(50, 50, 200, 30);
  fill(0);
  text("Digite valor: " + inputText, 60, 70);
}

// Função chamada ao receber dados da serial
void serialEvent(Serial myPort) {
  serialData = myPort.readStringUntil('\n');
  
  if (serialData != null) {
    // Remover espaços em branco e quebras de linha
    serialData = trim(serialData);
    
    // Dividir os dados em partes (esperando 3 valores separados por espaço)
    String[] data = split(serialData, ' ');
    
    if (data.length == 3) {
      setpoint = int(data[0]);
      rpm = int(data[1]);
      mediaPwm = int(data[2]);
    }
  }
}

// Função para capturar a entrada de texto
void keyPressed() {
  if (key == BACKSPACE) {
    if (inputText.length() > 0) {
      inputText = inputText.substring(0, inputText.length() - 1);
    }
  } else if (key != ENTER) {
    inputText += key;
  }
}

// Função para enviar o valor digitado para o ESP32
void enviarValor() {
  valorParaEnviar = int(inputText);  // Converter para número
  myPort.write(valorParaEnviar + "\n");  // Enviar o valor pela serial
  
  // Limpar a caixa de texto após o envio
  inputText = "";
}
