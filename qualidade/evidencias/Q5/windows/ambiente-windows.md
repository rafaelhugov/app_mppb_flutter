# Ambiente de Execução Windows Físico — Q5 End-to-End

## 1. Identificação do Host e Sistema Operacional
- **Sistema Operacional Host**: Microsoft Windows (físico)
- **Usuário**: `rafae`
- **Diretório do Projeto**: `C:\Users\rafae\projetosMPPB\app_mppb_flutter`
- **Branch Ativa**: `qualidade/q5-e2e`
- **Hash Base**: `589f4a7` (checkpoint vindo do Linux)
- **Patch Local Aplicado**: `version: 4.0.0+69` -> `version: 4.0.0+72` em `pubspec.yaml` (estritamente de acordo com o item 2 do protocolo).

## 2. Ferramentas e SDKs
- **Flutter SDK**: `C:\Users\rafae\flutter\bin\flutter.bat`
  - Flutter 3.44.3 • channel stable • commit `e1fd963c6f6922bd32afde2e9698a363cd0406d2`
  - Dart SDK 3.12.2
- **Java / JDK**: `C:\Program Files\Android\Android Studio\jbr` (OpenJDK 25)
- **Android SDK**: `C:\Users\rafae\AppData\Local\Android\Sdk`
  - `cmdline-tools`: versão oficial Google `latest` (19.0)
  - `platform-tools`: ADB versão 36.0.0
  - `platforms`: `android-36`
  - `build-tools`: `36.0.0`
  - Licenças Android: 100% aceitas (`flutter doctor --android-licenses`)

## 3. Dispositivo Físico Conectado
- **Fabricante / Modelo**: Samsung Galaxy A52 (SM-A525M)
- **Device Serial / ID**: `RX8RC09H70X`
- **Versão do Android**: Android 14 (API Level 34)
- **Arquitetura de CPU**: `arm64-v8a`
- **Conexão**: Cabo físico USB com Depuração USB ativada e chave RSA autorizada
- **Estabilidade ADB**: Validada com 5/5 testes consecutivos de ping/status antes e durante os testes. Nenhuma desconexão ou estado offline observado.

## 4. Configurações de Execução
- **Flutter Config**: `flutter config --no-enable-windows-desktop` (para evitar conflito de symlinks sem Developer Mode do Windows).
- **Dart Defines Utilizados nos Testes**:
  - `API_URL=https://aplicativo-mppb-homolog.mppb.mp.br`
  - `Q5_E2E_DISABLE_FCM=true`
- **Flavor**: `homolog`
- **Target do APK**: `lib/main.dart`
- **Package ID**: `br.mp.mppbapp.app.homolog`
