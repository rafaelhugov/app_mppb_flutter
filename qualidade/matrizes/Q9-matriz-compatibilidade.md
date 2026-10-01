# Q9 — Matriz de Compatibilidade

**Fase:** Q9 — Compatibilidade  
**Data:** 01/10/2026  
**Status:** Congelado / Concluído  
**Branch:** `qualidade/q9-compatibilidade`  
**Escopo Canônico:** `qualidade/relatorios/Q1-relatorio-final.md` (Linha 67, item Q9: *Android / iOS / web / resoluções / orientação / PDF / compartilhamento nativo*) e requisitos funcionais `RF-001`, `RF-009`, `RF-012`, `RF-019`

---

## 1. Critérios de Classificação

Cada cenário recebe estritamente uma classificação:
- **`PASSOU`**: Validação estática ou dinâmica comprovada com evidência reproduzível no escopo auditado.
- **`FALHOU`**: Incompatibilidade, defeito impeditivo, regressão ou quebra de contrato comprovada.
- **`PARCIAL`**: Atendido parcialmente com ressalva objetiva, cobertura incompleta ou runtime multiplataforma não aferido.
- **`N/A`**: Não aplicável ao escopo ou arquitetura suportada pelo produto.
- **`BLOQUEADO`**: Não executado exclusivamente por limitação técnica de infraestrutura ou hardware inacessível.

---

## 2. Matriz Consolidada de Compatibilidade (22 Cenários)

| ID | Domínio | Cenário Auditado | Método de Validação | Classificação | Evidência / Justificativa Objetiva |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Q9-AND-01** | Android | Configuração de SDK (`minSdk=24`, `targetSdk=36`, `compileSdk=36`) | Auditoria Estática (`build.gradle.kts`, `local.properties`) | **PASSOU** | Piso de instalação configurado em Android 7.0 / API 24 (`minSdk = 24`). Alvo compilado (`targetSdk = 36`) está **conforme com o requisito atual da Google Play** para novos apps e atualizações móveis em 01/10/2026 (`targetSdk >= 36`). |
| **Q9-AND-02** | Android | Arquiteturas Suportadas (`arm64-v8a`, `armeabi-v7a`, `x86_64`) | Auditoria Estática e Gradle ABI defaults | **PASSOU** | O Flutter gera suporte a todas as 3 ABIs no build padrão/homologação. |
| **Q9-AND-03** | Android | Permissões Declaradas e Visibilidade de Pacotes | Análise do Manifest Consolidado | **PASSOU** | Permissões declaradas mínimas e seguras (`INTERNET`, `USE_BIOMETRIC`, `POST_NOTIFICATIONS`); queries declaradas para web, e-mail e PDF. |
| **Q9-AND-04** | Android | Compilação APK Homolog Debug | `flutter build apk --debug --flavor homolog` | **PASSOU** | APK gerado com sucesso em `build/app/outputs/flutter-apk/app-homolog-debug.apk` (220 MB) em 43.8s. |
| **Q9-AND-05** | Android | Runtime em Dispositivo Físico (Samsung Galaxy A52) | Execução interativa via ADB | **BLOQUEADO** | **EVIDÊNCIA HERDADA Q8-R01**: Android 14 / arm64 físico validado em modo PROFILE (Galaxy A52). **Q9**: Nova execução física bloqueada por indisponibilidade de sinal de dados USB/ADB no host Windows (`Present: False` no subsistema PnP). Não se extrapola para API 24–36. |
| **Q9-AND-06** | Android | Tratamento de Teclado e Redimensionamento | Análise de `windowSoftInputMode` | **PASSOU** | Configurado como `adjustResize` na `MainActivity`, garantindo ajuste de viewport sob teclado virtual. |
| **Q9-AND-07** | Android | Política de Cleartext Traffic | Análise de segurança S8 e Manifest | **PASSOU** | `android:usesCleartextTraffic="false"` estritamente configurado, impedindo tráfego HTTP desprotegido. |
| **Q9-IOS-01** | iOS | Deployment Target (`IPHONEOS_DEPLOYMENT_TARGET = 13.0`) | Análise Estática `project.pbxproj` | **PASSOU** | Deployment target configurado em iOS 13.0; compatibilidade real depende das versões de iOS suportadas por cada modelo; runtime iOS não aferido na Q9. |
| **Q9-IOS-02** | iOS | Configuração de Permissões e Schemes em `Info.plist` | Análise Estática `Info.plist` | **PARCIAL** | `NSFaceIDUsageDescription` declarada. Contudo, ausência de `LSApplicationQueriesSchemes` impede que `canLaunchUrl` retorne `true` no iOS 9+ para links externos (`https`, `mailto`), violando exigência da documentação oficial do `url_launcher`. |
| **Q9-IOS-03** | iOS | Suporte a Firebase e FCM no iOS | Análise de `firebase_options.dart` e `push_notification_service.dart` | **PARCIAL** | Firebase iOS não configurado (`GoogleService-Info.plist` ausente; options lança `UnsupportedError`). FCM é desabilitado intencionalmente em tempo de execução no iOS (`isSupportedPlatform == false`), evitando crash, mas limitando funcionalidade push ao Android. |
| **Q9-IOS-04** | iOS | Runtime em Dispositivo / Simulador iOS | Execução dinâmica iOS | **BLOQUEADO** | **Limitação de Ambiente**: O host de desenvolvimento é Windows 11 Pro 64-bit; macOS, Xcode e simuladores iOS são estritamente inacessíveis neste ambiente. |
| **Q9-IOS-05** | iOS | Armazenamento Seguro e Biometria no iOS | Análise dos plugins `flutter_secure_storage` e `local_auth` | **PASSOU** | Plugins com suporte de ecossistema para Keychain (`kSecClassGenericPassword`) e biometria (`LAContext`/Face ID). |
| **Q9-WEB-01** | Web | Suporte à Plataforma Web | Análise de Arquitetura e Escopo | **N/A** | **N/A — Plataforma não suportada pelo produto mobile**. O aplicativo MPPB é um produto móvel restrito a Android e iOS; recursos essenciais (FCM background, biometria nativa) não são mantidos para web. |
| **Q9-LAY-01** | Layout | Breakpoints Responsivos do App (`MppbResponsive`) | Testes de Unidade (`test/core/ui/responsive_layout_test.dart`) | **PASSOU** | Breakpoints `compact` (<600), `medium` (600-839), `expanded` (840-1199) e `large` (>=1200) classificados corretamente, com paddings e colunas correspondentes. |
| **Q9-LAY-02** | Layout | Suporte a Orientação (Retrato e Paisagem) | Análise de Manifest, Plist e Layout | **PASSOU** | Orientações retrato e paisagem habilitadas em Android e iOS. Telas críticas utilizam `OrientationBuilder` e `MppbResponsive.fromSize`. |
| **Q9-LAY-03** | Layout | Ausência de Overflows em Testes Automatizados | Execução de `flutter test` (187 testes) | **PASSOU** | **PASSOU NO CONJUNTO DE VIEWPORTS AUTOMATIZADOS**. Todos os 187 testes automatizados executados sem erros de layout ou exceções de `RenderFlex overflow`. Não se extrapola para ausência global em todas as resoluções físicas possíveis. |
| **Q9-LAY-04** | Layout | Modo Claro / Modo Escuro | Auditoria de Tema em `lib/main.dart` | **PARCIAL** | Tema Claro implementado com cores institucionais do MPPB (`#8F2A1D`). Tema Escuro não implementado (`darkTheme` ausente no `MaterialApp.router`). App mantém tema claro mesmo com SO em Dark Mode. |
| **Q9-NAT-01** | Recursos Nativos | Abertura e Manipulação de Documentos PDF | Análise de `printing`, `pdf` e `<queries>` | **PARCIAL** | Configuração arquitetural e suporte a intent/queries de PDF validados estaticamente; runtime nativo multiplataforma não aferido. |
| **Q9-NAT-02** | Recursos Nativos | Compartilhamento Nativo de Conteúdo e Links | Análise de `share_plus` e intents de compartilhamento | **PARCIAL** | Configuração arquitetural validada (`Intent.ACTION_SEND` e `UIActivityViewController`); runtime nativo multiplataforma não aferido. |
| **Q9-DEP-01** | Dependências | Suporte dos 22 Pacotes em Android e iOS | Auditoria de `pubspec.yaml` e documentação | **PASSOU** | Distinguindo suporte de pacote de configuração do app: todas as 22 dependências possuem suporte declarado no ecossistema para Android e iOS. |
| **Q9-DEP-02** | Dependências | Risco de Depreciação / Breaking Changes | Logs de build Gradle e `flutter analyze` | **PARCIAL** | Compilação aprovada, com emissão de warning oficial: plugins `firebase_core` e `share_plus` aplicam Kotlin Gradle Plugin (KGP) diretamente. Recomenda-se avaliar atualização para versão compatível com Built-in Kotlin em ciclo próprio de dependências. |
| **Q9-BCK-01** | Backend | Neutralidade de Plataforma dos Contratos REST | Análise dos contratos Q3/Q4 e DTOs JSON | **PASSOU** | Contratos baseados em RFC 8259 (JSON UTF-8) e RFC 6750 (`Authorization: Bearer <token>`). O cliente consome via Dio em Dart, que utiliza os adaptadores nativos sem quebra de contrato em nenhuma plataforma. |

---

## 3. Síntese Quantitativa da Matriz (Matematicamente Exata)

```text
======================================================================
  SÍNTESE QUANTITATIVA DA MATRIZ Q9 — COMPATIBILIDADE
======================================================================
  [PASSOU]     13 cenários ( 59,1%)
  [PARCIAL]     6 cenários ( 27,3%)
  [BLOQUEADO]   2 cenários (  9,1%)
  [N/A]         1 cenário  (  4,5%)
  [FALHOU]      0 cenários (  0,0%)
======================================================================
  TOTAL        22 cenários (100,0%)
======================================================================
```

- **PASSOU (13):** `Q9-AND-01`, `Q9-AND-02`, `Q9-AND-03`, `Q9-AND-04`, `Q9-AND-06`, `Q9-AND-07`, `Q9-IOS-01`, `Q9-IOS-05`, `Q9-LAY-01`, `Q9-LAY-02`, `Q9-LAY-03`, `Q9-DEP-01`, `Q9-BCK-01`.
- **PARCIAL (6):** `Q9-IOS-02`, `Q9-IOS-03`, `Q9-LAY-04`, `Q9-NAT-01`, `Q9-NAT-02`, `Q9-DEP-02`.
- **BLOQUEADO (2):** `Q9-AND-05` (runtime Android físico bloqueado por indisponibilidade USB/ADB no Windows), `Q9-IOS-04` (runtime iOS bloqueado por ausência de host macOS/Xcode).
- **N/A (1):** `Q9-WEB-01` (plataforma não suportada pelo produto mobile).
- **FALHOU (0):** Nenhuma falha impeditiva ou regressão de código.
