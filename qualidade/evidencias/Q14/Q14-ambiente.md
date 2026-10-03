# Q14 — Registro de Ambiente e Artefato sob Teste

**Data do Registro:** 02/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final

---

## 1. Identificação dos Artefatos Canônicos

### 1.1 Aplicação Mobile (Flutter)
- **Repositório:** `C:\Users\rafae\projetosMPPB\app_mppb_flutter`
- **Branch de Trabalho:** `qualidade/q14-uat-aceite-final`
- **Commit Base (HEAD):** `9da39a7` (`9da39a704cc18612a4c2e68cde50a808a74e5f21`)
- **Modificações Preservadas:** `pubspec.yaml` (`version: 4.0.0+69 → 4.0.0+72`) mantida estritamente unstaged fora dos commits da Q14.
- **Comando de Compilação do Artefato:**
  ```powershell
  flutter build apk --debug --flavor homolog -t lib/main.dart --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br
  ```
- **Caminho do Artefato Gerado:** `build\app\outputs\flutter-apk\app-homolog-debug.apk`
- **Hash Criptográfico (SHA-256):** `E8568216B139C5DFE13FD17D40A5AE471708D19B4851BECE1D6E776D8FADC81A`
- **Identificador do Pacote Instalado:** `br.mp.mppbapp.app.homolog`
- **Verificação via `dumpsys package` no Aparelho:**
  - `versionCode=72`
  - `versionName=4.0.0`
  - `minSdk=24`
  - `targetSdk=36`
  - `lastUpdateTime=2026-10-02 21:52:41`
  - `signatures=PackageSignatures{...}`

### 1.2 Serviço Backend (Spring Boot REST API)
- **Repositório:** `C:\Users\rafae\projetosMPPB\spring-boot\restapi`
- **Branch de Trabalho:** `qualidade/q14-uat-aceite-final`
- **Commit Base (HEAD):** `12ebbe7` (`12ebbe7a3d047601102622e296052d568b8d156c`)
- **Working Tree:** Limpo (sem alterações pendentes)
- **Módulos Relevantes:** `restapi-common` (11 testes) e `mobile-service` (158 testes)

---

## 2. Dispositivo Físico de Homologação

- **Fabricante / Modelo:** Samsung Galaxy A52 (`SM-A525M`)
- **Identificador ADB (Serial):** `RX8RC09H70X`
- **Versão do Sistema Operacional:** Android 14
- **Nível de API:** 34
- **Camada de Interface:** One UI 6.1
- **Resolução de Tela:** 1080 x 2400 pixels
- **Conectividade Utilizada:** Wi-Fi institucional e link de dados móveis com internet ativa

---

## 3. Endpoints e Auditoria de Proveniência Canônica

### 3.1 Endpoint Oficial de Homologação
- **URL Canônica:** `https://aplicativo-mppb-homolog.mppb.mp.br`
- **Serviço de Autenticação:** `https://auth-api.mppb.mp.br`

### 3.2 Auditoria de Proveniência
A auditoria técnica da árvore de código e dos scripts oficiais de automação comprovou a origem canônica do endpoint:
1. `scripts/build/build_apk.sh` (linhas 21-22):
   ```bash
   DEFAULT_API_URL="https://aplicativo-mppb-homolog.mppb.mp.br"
   --dart-define=API_URL="${API_URL:-$DEFAULT_API_URL}"
   ```
2. `scripts/build/build_aab.sh`:
   Configura idêntico `--dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br`.
3. `lib/core/network/api_client.dart`:
   Define o fallback e parse oficial a partir de `const String.fromEnvironment('API_URL')`.
4. Relatórios históricos das fases Q5, Q8, Q10, Q11 e Q13 documentam formalmente a conectividade em `https://aplicativo-mppb-homolog.mppb.mp.br`.
5. A menção pontual a `https://app-homolog.mppb.mp.br` consistiu exclusivamente em abreviação textual informal em documentações anteriores, não correspondendo a qualquer alteração de infraestrutura ou configuração de compilação.
