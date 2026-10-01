# Evidência Q10 — Auditoria Estática de Instalação e Configuração iOS

Data: 01/10/2026  
Ambiente de Execução: Host Windows 11 (sem macOS / Xcode local)  
Classificação de Runtime: **BLOQUEADO POR LIMITAÇÃO DE AMBIENTE**

---

## 1. Justificativa do Bloqueio de Runtime

A compilação de binários nativos iOS (`.ipa`), a instalação via `xcrun/ideviceinstaller` ou a execução em simuladores Apple exigem o ambiente macOS com a suíte de ferramentas do Xcode Developer Tools. Como a estação de trabalho de validação é Windows 11, o ciclo dinâmico de instalação, atualização e Keychain em dispositivo/simulador iOS foi formalmente classificado como **BLOQUEADO POR LIMITAÇÃO DE AMBIENTE**.

Nenhum resultado de runtime iOS foi simulado ou declarado indevidamente como aprovado.

---

## 2. Auditoria Estática dos Arquivos de Configuração iOS

A integridade estrutural do projeto iOS foi inspecionada diretamente no diretório `ios/`:

### A. Metadados do Aplicativo (`ios/Runner/Info.plist`)
- **CFBundleDisplayName**: `MPPB+` (correto para exibição pública).
- **CFBundleName**: `app_mppb_flutter`.
- **CFBundleShortVersionString**: Mapeado dinamicamente para `$(FLUTTER_BUILD_NAME)` (consome a versão do `pubspec.yaml`).
- **CFBundleVersion**: Mapeado dinamicamente para `$(FLUTTER_BUILD_NUMBER)` (consome o build number do `pubspec.yaml`, ex: `72`).
- **NSFaceIDUsageDescription**:
  ```xml
  <key>NSFaceIDUsageDescription</key>
  <string>A biometria é necessária para acessar a Carteira Funcional offline de forma segura.</string>
  ```
  Mensagem clara e em conformidade com as diretrizes da App Store para uso de biometria.

### B. Identificador de Pacote (`ios/Runner.xcodeproj/project.pbxproj`)
- Linhas 385, 564, 586:
  ```text
  PRODUCT_BUNDLE_IDENTIFIER = com.example.appMppbFlutter;
  ```
- **Achado de Auditoria**: O identificador de pacote no projeto Xcode ainda é o identificador padrão do template Flutter (`com.example.appMppbFlutter`). Para publicação em produção e segregação de ambientes (homolog vs prod) no ecossistema iOS, deve ser atribuído um Bundle ID institucional (ex: `br.mp.mppbapp.app`). Documentado em `RISCO-Q10-002`.

### C. Configurações de Build Flutter (`ios/Flutter/Generated.xcconfig`)
- Confirmado consumo do versionamento canônico:
  - `FLUTTER_BUILD_NAME=4.0.0`
  - `FLUTTER_BUILD_NUMBER=72`
- Arquiteturas excluídas: `armv7` (32-bit descartado corretamente) e `i386`.

### D. Dependências e Firebase
- `Podfile`: Inexistente no controle de versão (o ecossistema de pods é gerado dinamicamente pelo Flutter no primeiro `pod install` em ambiente macOS).
- `GoogleService-Info.plist`: Inexistente em `ios/Runner/`. Para que o Firebase Cloud Messaging e Analytics funcionem no iOS, este arquivo deve ser provisionado no console Firebase da Apple.
