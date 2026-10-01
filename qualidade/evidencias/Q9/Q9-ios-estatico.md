# Q9 — Evidência de Auditoria Estática iOS

**Fase:** Q9 — Compatibilidade  
**Data:** 01/10/2026  
**Status:** Validado Estaticamente / Runtime Não Aferido por Limitação de Ambiente  

---

## 1. Classificação Metodológica Estrita

- **VALIDADO ESTATICAMENTE:** Configurações de projeto Xcode (`project.pbxproj`), `Info.plist`, código-fonte Dart condicional de inicialização de plataforma, dependências com suporte a Darwin/CocoaPods.
- **NÃO AFERIDO POR LIMITAÇÃO DE AMBIENTE:** Execução em runtime, montagem do harness em simulador iOS, empacotamento IPA, testes instrumentados XCTest. O host operacional é Windows 11 Pro 64-bit; máquinas macOS e ferramental Apple (Xcode, `simctl`, `xcodebuild`) não estão disponíveis.

---

## 2. Configurações de Projeto e Deployment Target

A análise estática do arquivo `ios/Runner.xcodeproj/project.pbxproj` confirmou:
- **`IPHONEOS_DEPLOYMENT_TARGET`:** `13.0` (configurado de forma idêntica em `Debug`, `Release` e `Profile`).
- **Compatibilidade do SO:** Deployment target configurado em iOS 13.0. A compatibilidade real depende das versões de iOS suportadas por cada modelo de dispositivo Apple; o runtime iOS não foi aferido na fase Q9.
- **Bundle Identifier:** `br.mp.mppbapp.app`
- **Assinatura de Código:** Configurada para assinatura de desenvolvimento padrão do Flutter (`CODE_SIGN_STYLE = Automatic`).

---

## 3. Permissões e Declarações em `Info.plist`

O arquivo `ios/Runner/Info.plist` foi auditado e apresenta as seguintes chaves de privacidade e comportamento:

### 3.1 Biometria (Face ID)
```xml
<key>NSFaceIDUsageDescription</key>
<string>A biometria é necessária para acessar a Carteira Funcional offline de forma segura.</string>
```
- **Conformidade:** Declarada corretamente. Atende às exigências da Apple para utilização da API `LocalAuthentication` no iPhone e iPad.

### 3.2 Orientações de Interface Suportadas
- **iPhone (`UISupportedInterfaceOrientations`):**
  - `UIInterfaceOrientationPortrait`
  - `UIInterfaceOrientationLandscapeLeft`
  - `UIInterfaceOrientationLandscapeRight`
- **iPad (`UISupportedInterfaceOrientations~ipad`):**
  - `UIInterfaceOrientationPortrait`
  - `UIInterfaceOrientationPortraitUpsideDown`
  - `UIInterfaceOrientationLandscapeLeft`
  - `UIInterfaceOrientationLandscapeRight`

---

## 4. Gaps e Incompatibilidades Concretas Identificadas para iOS

### 4.1 GAP-Q9-IOS-01: Ausência de `LSApplicationQueriesSchemes`
- **Problema Concreto:** O arquivo `ios/Runner/Info.plist` **não declara** a chave `<key>LSApplicationQueriesSchemes</key>`.
- **Exigência Oficial:** A documentação oficial do plugin `url_launcher` estabelece que todos os esquemas consultados pelo método `canLaunchUrl()` devem estar expressamente declarados em `LSApplicationQueriesSchemes`.
- **Impacto em Tempo de Execução:** A partir do iOS 9, chamadas a `canLaunchUrl()` retornam sistematicamente `false` para qualquer esquema externo (`https`, `http`, `mailto`, `tel`) que não esteja previamente listado nessa chave.
- **Telas Afetadas:**
  - `mppb_app_bar.dart` (abertura de links do portal)
  - `noticias_page.dart` e `news_carousel.dart` (leitura de notícia externa)
  - `diario_oficial_page.dart` (download e visualização externa do Diário Oficial)
  - `servico_links_externos.dart` (links de telefones e e-mails de promotorias)
- **Classificação:** Defeito de compatibilidade estática mantido como **`PARCIAL`** no cenário `Q9-IOS-02`.

### 4.2 GAP-Q9-IOS-02: Firebase iOS Não Configurado
- **Problema Concreto:** O arquivo `GoogleService-Info.plist` **não existe** no repositório (`ios/Runner/GoogleService-Info.plist`).
- **Implementação em Dart:** Em `lib/firebase_options.dart` (linhas 28–32):
  ```dart
  case TargetPlatform.iOS:
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for ios - '
      'you can reconfigure this by running the FlutterFire CLI again.',
    );
  ```
- **Proteção por Design no App:** A classe `PushNotificationService` (linhas 93–95) previne a chamada no iOS:
  ```dart
  static bool get isSupportedPlatform {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }
  ```
- **Consequência:** O aplicativo foi desenhado intencionalmente para **não inicializar o Firebase no iOS**, evitando um crash imediato ao inicializar `MyApp`. Contudo, isso implica que **notificações push (FCM) não funcionam no iOS**.
- **Classificação:** Mapeado como **`PARCIAL`** no cenário `Q9-IOS-03`.

### 4.3 GAP-Q9-IOS-03: Ausência de Capabilities de Background Modes
- **Problema Concreto:** O `Info.plist` não declara `UIBackgroundModes` com `remote-notification`. Caso o projeto decida habilitar FCM para iOS futuramente, será indispensável adicionar essa capability e gerar os certificados APNs correspondentes.

---

## 5. Plugins Nativos com Suporte iOS (Suporte do Ecossistema)

Distingue-se o suporte técnico oferecido pelo plugin no ecossistema Darwin da configuração ativa no app:
- **Biometria:** `local_auth` possui implementação em `local_auth_darwin` (`LAContext`, biometria com Touch ID / Face ID).
- **Armazenamento Seguro:** `flutter_secure_storage` possui implementação em `flutter_secure_storage_darwin` (Apple Keychain Services com `kSecClassGenericPassword`).
- **Conectividade:** `connectivity_plus` utiliza o framework `Network` (`NWPathMonitor`).
- **Impressão/PDF:** `printing` utiliza `UIPrintInteractionController`.
- **Compartilhamento:** `share_plus` utiliza `UIActivityViewController`.
- **Seleção de Arquivos:** `file_picker` utiliza `UIDocumentPickerViewController`.
