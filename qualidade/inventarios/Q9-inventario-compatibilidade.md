# Q9 — Inventário de Compatibilidade do Aplicativo MPPB

**Fase:** Q9 — Compatibilidade  
**Data:** 01/10/2026  
**Status:** Congelado / Concluído  
**Branch:** `qualidade/q9-compatibilidade`  
**Escopo Canônico:** `qualidade/relatorios/Q1-relatorio-final.md` (Linha 67, item Q9: *Android / iOS / web / resoluções / orientação / PDF / compartilhamento nativo*) e requisitos funcionais `RF-001`, `RF-009`, `RF-012`, `RF-019`

---

## 1. Visão Geral

Este documento consolida o inventário técnico de compatibilidade de plataformas, sistemas operacionais, componentes nativos, permissões, recursos de compartilhamento/PDF e dependências do aplicativo MPPB Flutter.

A auditoria divide-se estritamente entre:
1. **Configuração e Auditoria Estática:** Especificações declaradas em manifests, arquivos Gradle, Xcode/plist e código-fonte Dart.
2. **Execução em Runtime:** Comportamento dinâmico em dispositivos/emuladores reais (com distinção entre evidência dinâmica herdada da Q8-R01 e bloqueios de reexecução na Q9).

---

## 2. Plataformas e Ambientes do Escopo Canônico

| Plataforma | Suporte Oficial no Projeto | Target / Configuração | Status de Validação na Q9 |
| :--- | :--- | :--- | :--- |
| **Android** | Sim (Primária) | `minSdk = 24`, `targetSdk = 36`, `compileSdk = 36` | **Auditado Estaticamente e Compilado (APK Homolog Debug)**; Runtime Android 14 com evidência herdada da Q8-R01; nova execução física bloqueada por limitação USB/ADB |
| **iOS** | Sim (Secundária) | `IPHONEOS_DEPLOYMENT_TARGET = 13.0` | **Auditado Estaticamente**; Runtime não aferido por ausência de host macOS/Xcode |
| **Web** | Não suportado pelo produto mobile | Compilação restrita / sem suporte FCM e biometria | **N/A — Plataforma não suportada pelo produto mobile** (o projeto MPPB é desenhado exclusivamente para dispositivos móveis) |

---

## 3. Especificações Técnicas Android

### 3.1 SDK e Versões
- **Namespace:** `br.mp.mppbapp.app`
- **ApplicationId:** `br.mp.mppbapp.app` (Produção), `br.mp.mppbapp.app.homolog` (Homologação)
- **Compile SDK:** `36` (Android 16 / Vanilla Ice Cream Preview)
- **Min SDK:** `24` (Piso de instalação configurado em Android 7.0 / API 24; não implica garantia de funcionamento em todas as versões intermediárias sem teste dinâmico)
- **Target SDK:** `36` (Android 16) — **Conforme com o requisito atual da Google Play** para novos aplicativos e atualizações móveis em 01/10/2026 (`targetSdk >= 36`)
- **Java Compatibility:** `JavaVersion.VERSION_17` (Source e Target)
- **Kotlin JVM Target:** `JVM_17`
- **NDK Version:** Gerenciada pelo Flutter SDK (`flutter.ndkVersion`)

### 3.2 Arquiteturas Suportadas
O Flutter compila por padrão para as seguintes ABIs em Android:
- `arm64-v8a` (Dispositivos modernos de 64 bits — ex.: Samsung Galaxy A52)
- `armeabi-v7a` (Dispositivos legados de 32 bits)
- `x86_64` (Emuladores de 64 bits e dispositivos Intel/AMD)

### 3.3 Permissões Declaradas e Nativas

| Permissão | Declaração | Tipo / Proteção | Comportamento em Runtime |
| :--- | :--- | :--- | :--- |
| `android.permission.INTERNET` | `AndroidManifest.xml` | Normal (Install-time) | Concedida automaticamente na instalação. |
| `android.permission.USE_BIOMETRIC` | `AndroidManifest.xml` | Normal (BiometricPrompt) | Não exige dialog de permissão; acionada via API do sistema. |
| `android.permission.POST_NOTIFICATIONS` | `AndroidManifest.xml` | Perigosa (Android 13+ / API 33+) | Exige solicitação explícita em runtime no primeiro acionamento. |
| `android.permission.ACCESS_NETWORK_STATE` | Merged (`connectivity_plus`) | Normal (Install-time) | Utilizada para detecção de status de conexão de rede. |
| `android.permission.WAKE_LOCK` | Merged (`firebase_messaging`) | Normal (Install-time) | Utilizada para entrega de pushes com tela desligada. |
| `android.permission.USE_FINGERPRINT` | Merged (`local_auth_android`) | Legado (Pre-API 28) | Retrocompatibilidade para biometria em Android 7 e 8. |

### 3.4 Visibilidade de Pacotes (`<queries>`)
- `ACTION_PROCESS_TEXT` (`text/plain`): Integração do motor de texto do Flutter.
- `ACTION_VIEW` (`https`, `http`): Abertura de links em navegadores externos via `url_launcher`.
- `ACTION_SENDTO` (`mailto`): Envio de e-mails para contatos institucionais.
- `ACTION_VIEW` (`application/pdf`): Visualização de contracheques e diários oficiais.
- `ACTION_GET_CONTENT` (`*/*`): Seleção de anexos na Ouvidoria via `file_picker`.

### 3.5 Parâmetros de Janela e Segurança
- `android:usesCleartextTraffic="false"`: Tráfego HTTP em texto puro estritamente bloqueado em builds de produção/release (conforme auditoria de segurança S8).
- `android:windowSoftInputMode="adjustResize"`: Redimensionamento automático do layout na abertura do teclado virtual.
- `android:configChanges`: Trata internamente rotação de tela, escala de fonte, tamanho de tela e modo noturno sem reiniciar a Activity.

---

## 4. Especificações Técnicas iOS

### 4.1 Deployment Target e Identificadores
- **Bundle Identifier:** `com.example.appMppbFlutter`
> **CORREÇÃO DOCUMENTAL IDENTIFICADA DURANTE Q10:** O projeto iOS ainda utiliza o bundle identifier de template (`com.example.appMppbFlutter`), necessitando atribuição institucional prévia à distribuição App Store.
- **Bundle Display Name:** `MPPB+`
- **Deployment Target (`IPHONEOS_DEPLOYMENT_TARGET`):** `13.0` (configurado em iOS 13.0; a compatibilidade real depende das versões de iOS suportadas por cada modelo físico; runtime iOS não aferido na Q9).
- **Scene Delegate:** Suportado (`UIWindowSceneSessionRoleApplication`)
- **Indireção de Entrada:** `UIApplicationSupportsIndirectInputEvents = true`

### 4.2 Orientações Suportadas
- **iPhone:** Retrato (`UIInterfaceOrientationPortrait`), Paisagem Esquerda (`LandscapeLeft`), Paisagem Direita (`LandscapeRight`).
- **iPad:** Retrato, Retrato Invertido, Paisagem Esquerda, Paisagem Direita.

### 4.3 Permissões em `Info.plist`
- `NSFaceIDUsageDescription`: "A biometria é necessária para acessar a Carteira Funcional offline de forma segura."

### 4.4 Gaps Identificados na Auditoria Estática iOS
1. **Ausência de `LSApplicationQueriesSchemes`:** O arquivo `ios/Runner/Info.plist` não declara as chaves de schemes permitidos (`https`, `http`, `mailto`, `tel`). A documentação oficial do `url_launcher` exige que schemes consultados por `canLaunchUrl` estejam declarados em `LSApplicationQueriesSchemes`. No iOS 9+, chamadas a `canLaunchUrl()` retornam `false` se o esquema não estiver declarado.
2. **Firebase iOS Não Configurado:** O arquivo `GoogleService-Info.plist` não existe no diretório `ios/Runner/`. Em `lib/firebase_options.dart`, a chamada para `TargetPlatform.iOS` lança explicitamente `UnsupportedError`.
3. **Restrição por Design no FCM:** Em `lib/core/notifications/push_notification_service.dart`, `isSupportedPlatform` é restrito a `TargetPlatform.android`. No iOS, a inicialização do Firebase é suprimida intencionalmente em tempo de execução, evitando crash, mas implicando ausência de suporte funcional a push FCM no iOS.
4. **Ausência de Capabilities de Background:** Não há chave `UIBackgroundModes` com `remote-notification` em `Info.plist`.

---

## 5. Recursos Nativos: PDF e Compartilhamento

1. **Abertura e Manipulação de PDF:**
   - Pacotes: `pdf` (geração de documentos) e `printing` (spooler nativo de impressão).
   - Manifest Android: Declaração de `ACTION_VIEW` com `mimeType="application/pdf"`.
   - Implementação iOS: Suporte Darwin via `UIPrintInteractionController`.
   - Status: Configuração e arquitetura validadas; runtime multiplataforma não aferido.
2. **Compartilhamento Nativo:**
   - Pacote: `share_plus`.
   - Android: `Intent.ACTION_SEND` / `Intent.createChooser`.
   - iOS: `UIActivityViewController`.
   - Status: Configuração e arquitetura validadas; runtime multiplataforma não aferido.

---

## 6. Inventário de Dependências Flutter (22 Pacotes)

> **Nota Metodológica:** Distingue-se expressamente o **Suporte da Dependência** (suporte técnico do plugin a nível de ecossistema) da **Configuração do Aplicativo** (existência das chaves, credenciais e wiring no código do app MPPB).

| Dependência | Versão Declarada | Suporte do Pacote Android | Suporte do Pacote iOS | Configuração no App MPPB | Observações de Compatibilidade |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `cupertino_icons` | `^1.0.8` | Sim | Sim | Sim | Ícones vetoriais Cupertino (Dart puro) |
| `flutter_riverpod` | `^3.3.2` | Sim | Sim | Sim | Gerenciamento de estado (Dart puro) |
| `go_router` | `^17.3.0` | Sim | Sim | Sim | Roteamento declarativo |
| `dio` | `^5.9.2` | Sim | Sim | Sim | Cliente HTTP multi-plataforma (Dart puro) |
| `flutter_secure_storage` | `^10.3.1` | Sim | Sim | Sim | Android Keystore / iOS Keychain |
| `qr_flutter` | `^4.1.0` | Sim | Sim | Sim | Renderização de QR Code na Carteira |
| `url_launcher` | `^6.3.0` | Sim | Sim | Parcial (iOS sem queries) | Requer `LSApplicationQueriesSchemes` no iOS |
| `intl` | `^0.20.2` | Sim | Sim | Sim | Internacionalização pt_BR |
| `google_fonts` | `^6.2.1` | Sim | Sim | Sim | Fontes dinâmicas |
| `flutter_svg` | `^2.0.10` | Sim | Sim | Sim | Gráficos vetoriais SVG |
| `font_awesome_flutter` | `^11.0.0` | Sim | Sim | Sim | Ícones tipográficos FontAwesome |
| `local_auth` | `^3.0.2` | Sim | Sim | Sim | Biometria nativa (BiometricPrompt / Face ID) |
| `connectivity_plus` | `^7.2.0` | Sim | Sim | Sim | Monitoramento de rede |
| `cached_network_image` | `^3.4.1` | Sim | Sim | Sim | Cache de imagens remotas |
| `just_the_tooltip` | `^0.0.12` | Sim | Sim | Sim | Tooltips para acessibilidade |
| `pdf` | `^3.11.1` | Sim | Sim | Sim | Geração de PDF em memória |
| `printing` | `^5.13.4` | Sim | Sim | Sim | Spooler de impressão nativa de PDF |
| `html` | `^0.15.4` | Sim | Sim | Sim | Parser DOM para notícias |
| `file_picker` | `^8.1.4` | Sim | Sim | Sim | Seletor de arquivos na Ouvidoria |
| `share_plus` | `^12.0.2` | Sim | Sim | Sim | Compartilhamento nativo (alerta KGP no build) |
| `firebase_core` | `^4.14.0` | Sim | Sim | Parcial (iOS sem plist) | Alerta KGP no build; iOS não configurado |
| `firebase_messaging` | `^16.6.0` | Sim | Sim | Parcial (desativado no iOS) | Push notifications FCM ativas apenas em Android |

---

## 7. Inventário de Layout Responsivo

### 7.1 Breakpoints do Sistema (`MppbResponsive`)
Definidos em `lib/core/ui/responsive_layout.dart`:
- **Compact:** `< 600 dp` (Smartphones em modo retrato)
- **Medium:** `600 dp` a `839 dp` (Tablets compactos e smartphones grandes em paisagem)
- **Expanded:** `840 dp` a `1199 dp` (Tablets médios em paisagem e telas expandidas)
- **Large:** `>= 1200 dp` (Tablets grandes / telas desktop)

### 7.2 Temas (Claro / Escuro)
- **Tema Claro:** Implementado via `ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF8F2A1D)), useMaterial3: true)`.
- **Tema Escuro:** **Não implementado**. O `MaterialApp.router` em `lib/main.dart` não fornece `darkTheme` nem `themeMode`. O aplicativo mantém renderização visual em tema claro, mesmo quando o sistema operacional do usuário está configurado em Dark Mode.
