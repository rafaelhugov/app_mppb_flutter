# Q9 — Rastreabilidade de Compatibilidade

**Fase:** Q9 — Compatibilidade  
**Data:** 01/10/2026  
**Status:** Congelado / Concluído  
**Branch:** `qualidade/q9-compatibilidade`  

---

## 1. Origem Canônica e Mapeamento

O escopo da fase **Q9 — Compatibilidade** tem sua definição de origem registrada formalmente no fechamento da fase Q1 em:
- **Documento:** `qualidade/relatorios/Q1-relatorio-final.md` (Tabela de Macro-Planejamento das Fases, Linha 67):
  > *| Q9 | Matriz Android/iOS/web, resolucoes, orientacao, PDF/compartilhamento nativo. |*
- **Rastreabilidade Funcional:** `qualidade/matrizes/Q1-rastreabilidade-funcional.md`:
  - `RF-001` (Inicialização/Home/conectividade e matriz de dispositivos) → Q2/Q5/Q7/Q9
  - `RF-009` (Contatos institucionais, links externos e acessibilidade) → Q2/Q5/Q9/Q11
  - `RF-012` (Carteira Funcional nativa, PDF e QR code) → Q2/Q3/Q4/Q5/Q7/Q9/Q10
  - `RF-019` (Navegação complementar, serviços e matriz de resoluções) → Q2/Q5/Q9/Q11

Em consonância com as regras da fase Q9, o escopo canônico foi executado seguindo o escopo canônico completo para Android, iOS, Web, Layout Responsivo, PDF, Compartilhamento Nativo, Dependências e Backend.

---

## 2. Matriz de Rastreabilidade Q9 (22 Cenários)

| Requisito / Escopo | Descrição do Requisito | Componentes no Código | Cenário Q9 | Arquivo de Evidência | Classificação |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RF-001 / AND-SDK** | Versões mínimas e alvos de SDK Android | `android/app/build.gradle.kts`, `local.properties` | `Q9-AND-01` | `qualidade/evidencias/Q9/Q9-android-compatibilidade.md` | **PASSOU** |
| **RF-001 / AND-ARCH** | Suporte às arquiteturas Android (64 e 32 bits) | `android/app/build.gradle.kts` | `Q9-AND-02` | `qualidade/evidencias/Q9/Q9-android-compatibilidade.md` | **PASSOU** |
| **RF-001 / AND-PERM** | Permissões declaradas e visibilidade de pacotes | `AndroidManifest.xml` (main e merged) | `Q9-AND-03` | `qualidade/evidencias/Q9/Q9-android-compatibilidade.md` | **PASSOU** |
| **RF-001 / AND-BUILD**| Compilação limpa do artefato APK | Gradle / Flutter Tooling | `Q9-AND-04` | `qualidade/evidencias/Q9/Q9-regressao.md` | **PASSOU** |
| **RF-001 / AND-RUN**  | Instalação, inicialização e navegação em hardware | Dispositivo físico Samsung Galaxy A52 | `Q9-AND-05` | `qualidade/evidencias/Q9/Q9-android-compatibilidade.md` | **BLOQUEADO** |
| **RF-001 / AND-KBD**  | Comportamento de teclado virtual e ajuste | `AndroidManifest.xml` (`adjustResize`) | `Q9-AND-06` | `qualidade/evidencias/Q9/Q9-android-compatibilidade.md` | **PASSOU** |
| **RF-001 / AND-SEC**  | Restrição estrita de cleartext HTTP | `AndroidManifest.xml` (`usesCleartextTraffic=false`) | `Q9-AND-07` | `qualidade/evidencias/Q9/Q9-android-compatibilidade.md` | **PASSOU** |
| **RF-001 / IOS-TGT**  | Deployment target e suporte de versões iOS | `ios/Runner.xcodeproj/project.pbxproj` | `Q9-IOS-01` | `qualidade/evidencias/Q9/Q9-ios-estatico.md` | **PASSOU** |
| **RF-009 / IOS-PLIST**| Declarações de permissões e schemes externos | `ios/Runner/Info.plist` | `Q9-IOS-02` | `qualidade/evidencias/Q9/Q9-ios-estatico.md` | **PARCIAL** |
| **RF-018 / IOS-FCM**  | Suporte a notificações push Firebase em iOS | `firebase_options.dart`, `push_notification_service.dart` | `Q9-IOS-03` | `qualidade/evidencias/Q9/Q9-ios-estatico.md` | **PARCIAL** |
| **RF-001 / IOS-RUN**  | Validação dinâmica em runtime iOS | macOS / Xcode / Simulador iOS | `Q9-IOS-04` | `qualidade/evidencias/Q9/Q9-ios-estatico.md` | **BLOQUEADO** |
| **RF-012 / IOS-SEC**  | Biometria e armazenamento seguro em iOS | `local_auth`, `flutter_secure_storage` | `Q9-IOS-05` | `qualidade/evidencias/Q9/Q9-ios-estatico.md` | **PASSOU** |
| **CAN-Q1 / WEB-PLT**  | Avaliação de suporte à plataforma Web | Código Flutter e arquitetura | `Q9-WEB-01` | `qualidade/inventarios/Q9-inventario-compatibilidade.md` | **N/A** |
| **RF-019 / LAY-BKPT** | Adaptação de layout por breakpoints de tela | `lib/core/ui/responsive_layout.dart` | `Q9-LAY-01` | `qualidade/evidencias/Q9/Q9-layout-responsivo.md` | **PASSOU** |
| **RF-019 / LAY-ORI**  | Suporte a rotação de tela retrato e paisagem | `AndroidManifest.xml`, `Info.plist`, `main_layout.dart` | `Q9-LAY-02` | `qualidade/evidencias/Q9/Q9-layout-responsivo.md` | **PASSOU** |
| **RF-001 / LAY-OVF**  | Ausência de overflow no conjunto de viewports | Testes de widget e layouts (`test/core/ui/`) | `Q9-LAY-03` | `qualidade/evidencias/Q9/Q9-layout-responsivo.md` | **PASSOU** |
| **RF-001 / LAY-THM**  | Suporte a Tema Claro e Tema Escuro | `lib/main.dart` (`ThemeData`) | `Q9-LAY-04` | `qualidade/evidencias/Q9/Q9-layout-responsivo.md` | **PARCIAL** |
| **CAN-Q1 / NAT-PDF**  | Abertura e manipulação nativa de PDF | `printing`, `pdf`, `<queries>` PDF | `Q9-NAT-01` | `qualidade/inventarios/Q9-inventario-compatibilidade.md` | **PARCIAL** |
| **CAN-Q1 / NAT-SHR**  | Compartilhamento nativo de links e textos | `share_plus`, intents de compartilhamento | `Q9-NAT-02` | `qualidade/inventarios/Q9-inventario-compatibilidade.md` | **PARCIAL** |
| **DEP-ALL / DEP-MAT** | Suporte dos 22 pacotes em Android e iOS | `pubspec.yaml`, `pubspec.lock` | `Q9-DEP-01` | `qualidade/evidencias/Q9/Q9-dependencias.md` | **PASSOU** |
| **DEP-ALL / DEP-KGP** | Análise de breaking changes e avisos do Gradle | `firebase_core`, `share_plus` | `Q9-DEP-02` | `qualidade/evidencias/Q9/Q9-dependencias.md` | **PARCIAL** |
| **BCK-ALL / BCK-CTR** | Neutralidade de plataforma dos contratos REST | Contratos Q3/Q4, Dio HTTP client | `Q9-BCK-01` | `qualidade/evidencias/Q9/Q9-regressao.md` | **PASSOU** |

---

## 3. Rastreabilidade com os Portões de Regressão

| Portão de Regressão | Ferramenta / Comando | Resultado | Status |
| :--- | :--- | :--- | :--- |
| **Análise Estática** | `flutter analyze` | No issues found! (ran in 117.7s) | **VERDE** |
| **Testes Automatizados** | `flutter test` | All tests passed! (187/187 passed in 13s) | **VERDE** |
| **Compilação Android** | `flutter build apk --debug --flavor homolog -t lib/main.dart` | `app-homolog-debug.apk` gerado em 43.8s | **VERDE** |
