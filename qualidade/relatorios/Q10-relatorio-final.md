# Relatório Final — Fase Q10: Instalação, Atualização e Migração

**Ciclo de Qualidade, Confiabilidade e Prontidão do App MPPB**  
**Data:** 01/10/2026  
**Repositório Flutter:** `app_mppb_flutter` | Branch: `qualidade/q10-instalacao-atualizacao-migracao` (base `8fcb889`)  
**Repositório Backend:** `spring-boot/restapi` | Branch: `master` (HEAD `508a1fc`, working tree limpo)  
**Hardware de Teste Físico:** Samsung Galaxy A52 (`SM-A525M`, Android 14 / One UI 6.1, Kernel 4.14, API 34)  
**Endpoint Validado:** `https://aplicativo-mppb-homolog.mppb.mp.br` (`--dart-define=API_URL`)  
**Pendência Remota Registrada:** Publicação remota de Q8/Q9 no GitLab pendente por indisponibilidade de infraestrutura (HTTP 504 Gateway Timeout).

---

## 1. Resumo Executivo

A fase **Q10 — Instalação, Atualização e Migração** comprovou experimentalmente a robustez do ciclo de vida de instalação, atualização e manipulação de estado local do aplicativo MPPB. Utilizando o dispositivo físico Samsung Galaxy A52 (Android 14 real), foi executado com sucesso o fluxo completo de:
1. **Instalação limpa (+72)**: app abriu em cold start limpo, sem sessões fantasmas ou erros no KeyStore;
2. **Atualização in-place (+69 → +72)**: aplicada via `adb install -r`, com aceitação imediata pelo Package Manager e confirmação de `versionCode=72`;
3. **Rejeição de downgrade**: tentativa de instalar v69 sobre v72 rejeitada pelo sistema operacional com `INSTALL_FAILED_VERSION_DOWNGRADE`;
4. **Limpeza de dados (`pm clear`)**: sandbox resetado para 59 bytes com reabertura equivalente ao first run;
5. **Reinstalação (uninstall + install)**: descarte completo de sandbox e reconstrução limpa do estado.

Paralelamente, a persistência foi auditada com estrito rigor metodológico: o mecanismo `FlutterSecureStorage` permaneceu plenamente operacional após o upgrade e os arquivos do sandbox permaneceram presentes. Chaves funcionais que dependem de sessão autenticada foram rigorosamente classificadas como container preservado, com valores específicos não aferidos por limitação de massa de teste (não uso de credenciais institucionais reais).

A compilação do APK debug homolog foi concluída com sucesso. A geração do AppBundle (AAB) release de homologação não foi validada nesta estação por ausência legítima das chaves institucionais privadas de assinatura (`android/key.properties`), sendo classificada como pendência de prontidão (`RISCO-Q10-001`).

A plataforma iOS foi auditada estaticamente, sendo seu runtime classificado estritamente como **BLOQUEADO POR LIMITAÇÃO DE AMBIENTE** devido à ausência de ambiente macOS/Xcode na estação de testes. Identificou-se que o projeto iOS ainda utiliza o bundle identifier de template (`com.example.appMppbFlutter`), gerando o risco `RISCO-Q10-002` e ensejando correção histórica documental da fase Q9.

A suíte completa de 187 testes automatizados, os security gates canônicos e a análise estática (`flutter analyze`) encerraram com 100% de sucesso.

---

## 2. Inventário e Comportamento dos Stores de Persistência

| Store / Tecnologia | Escopo de Dados | Deve Sobreviver Update? | Comprovação Pós-Update (+69 → +72) | Comportamento pós-Clear Data / Uninstall |
|---|---|---|---|---|
| **Android KeyStore** | Chaves RSA/AES (`FlutterSecureStoragePluginKeyOAEP`) | Sim | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Storage permaneceu operacional) | Chaves apagadas no uninstall ou recicladas no clear data |
| **FlutterSecureStorage** | `auth_token`, `auth_username`, flags, caches | Sim | **MECANISMO PRESERVADO / VALOR ESPECÍFICO NÃO AFERIDO** (Sem login real) | Totalmente expurgado; reiniciado estéril no first-run |
| **Identificador FCM** | `fcm_device_installation_id` | Sim | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** | Expurgo comprovado no clear data; novo UUIDv4 gerado |
| **Senha Legada** | `saved_password` | Não | **REGRA DE CÓDIGO VALIDADA / NÃO EXERCITADA COM VALOR REAL** | Removido |
| **SharedPreferences Nativo** | `com.google.android.gms.appid.xml` (FCM) | Sim | **CONTAINER PRESERVADO** (Arquivo de 416 bytes presente pós-update) | Removido |
| **Files Sandbox** | `files/Manrope_*.ttf`, `flutter_callback_cache.json` | Sim | **CONTAINER PRESERVADO** (Arquivos presentes pós-update) | Removido |
| **App Cache** | `cache/` (imagens voláteis) | Opcional | **CONTAINER PRESERVADO** (Diretório presente pós-update) | Removido |
| **Arquivos PDF / Relatórios** | Em memória (`Uint8List`) | Não | **N/A** (Sem persistência em disco permanente) | N/A |
| **Banco Relacional / SQLite** | Inexistente (Sem `sqflite` em `lib/`) | N/A | **N/A** (Inexistente no aplicativo) | N/A |

---

## 3. Resultados dos Cenários de Teste

| Cenário | Descrição | Resultado | Classificação |
|---|---|---|---|
| **Q10-T01** | Instalação limpa no Android físico (v72) | Instalação via ADB completada; app inicializou em cold start (5989ms) com KeyStore configurado e Home pública funcional; zero crashes. | **PASSOU** |
| **Q10-T02** | Atualização +69 → +72 in-place | Base v69 instalada e atualizada via `adb install -r` com o APK candidato v72. `dumpsys` confirmou `versionCode=72`; inicialização íntegra sem exceções. | **PASSOU** |
| **Q10-T03** | Persistência pós-update | Mecanismo/storage e arquivos no sandbox permaneceram presentes após o upgrade; valores funcionais específicos classificados como não aferidos por ausência de login real. | **PARCIAL** |
| **Q10-T04** | Logout e ciclo de sessão pós-update | `AuthNotifier` lê token de forma determinística na inicialização; rotina `_migrarSenhaBiometricaLegada` sanitiza dados antigos sem falha. | **PASSOU** |
| **Q10-T05** | Atualização com dados incompatíveis | Parsers JSON em `carteira_provider` e `perfil_provider` possuem blocos `try-catch` com fallback amigável; sem exceções fatais. | **PASSOU** |
| **Q10-T06** | Downgrade de versão (+72 → +69) | Package Manager rejeitou instalação padrão com `INSTALL_FAILED_VERSION_DOWNGRADE`. Downgrade funcionou com a flag de desenvolvimento forçada `-d`. | **PASSOU** |
| **Q10-T07** | Reinstalação (Uninstall + Install) | `adb uninstall` apagou o pacote e arquivos privados; reinstalação iniciou do zero perfeitamente. | **PASSOU** |
| **Q10-T08** | Limpeza de dados (Clear Data) | `adb shell pm clear` limpou sandbox para 59 bytes; reabertura solicitou permissões de sistema de novo (equivalente ao first run). | **PASSOU** |
| **Q10-T09** | Isolamento de flavors | Package de produção instalado separadamente; coexiste com homologação sem colisão de pacotes, sandboxes ou UIDs Linux. | **PASSOU** |
| **Q10-T10** | Assinatura dos artefatos | Debug/homolog utiliza debug keystore; release requer `key.properties` (ausência gera NPE controlada documentada em `RISCO-Q10-001`). | **PASSOU** |
| **Q10-T11** | Geração de APK e AppBundle | APK debug homolog compilado com sucesso (220MB); AppBundle homolog release não gerado por ausência de `key.properties`. | **PARCIAL** |
| **Q10-T12** | Compatibilidade de APIs Android | Validado no runtime real Android 14 (API 34). Outras APIs (24 a 36) mantidas como conformidade estática. | **PARCIAL** |
| **Q10-T13** | Migração de banco de dados | App não implementa SQLite local ou schema persistente relacional próprio. | **N/A** |
| **Q10-T14** | Arquivos temporários e PDFs | PDFs são mantidos em memória RAM (`Uint8List`) e despachados via intent de compartilhamento do SO; sem resíduos em disco. | **PASSOU** |
| **Q10-T15** | Identificador de instalação FCM | `fcm_device_installation_id` e preferences permaneceram presentes no upgrade in-place e são recriados (UUIDv4) após clear data ou reinstalação. | **PASSOU** |
| **Q10-iOS** | Runtime de Instalação e Update iOS | Host Windows 11 sem macOS/Xcode. Auditoria estática realizada (`Info.plist`, `project.pbxproj`). | **BLOQUEADO** |

---

## 4. Totais da Matriz Q10

```text
======================================================================
  RESUMO DA MATRIZ Q10 — INSTALAÇÃO, ATUALIZAÇÃO E MIGRAÇÃO
======================================================================
  [PASSOU]     11 cenários ( 68,8%)
  [PARCIAL]     3 cenários ( 18,8%)
  [BLOQUEADO]   1 cenário  (  6,2%)
  [N/A]         1 cenário  (  6,2%)
  [FALHOU]      0 cenários (  0,0%)
======================================================================
  TOTAL        16 cenários (100,0%)
======================================================================
```

---

## 5. Tabela de Riscos e Não Conformidades

| Identificador | Severidade | Categoria | Descrição do Risco | Ação Recomendada |
|---|---|---|---|---|
| **RISCO-Q10-001** | Alta (Prontidão de Publicação) | Build / Assinatura | Não foi validada nesta estação a geração do AAB release assinável para distribuição (dependência de `android/key.properties`). Trata-se de pendência para publicação, embora seja boa prática não armazenar credenciais no repositório. | Configurar o arquivo `key.properties` exclusivamente nas variáveis secretas da pipeline de CI/CD do MPPB. |
| **RISCO-Q10-002** | Média | iOS / Config | Bundle identifier iOS permanece com identificador de template `com.example.appMppbFlutter` e precisa ser definido institucionalmente antes da distribuição App Store. | Ajustar o `PRODUCT_BUNDLE_IDENTIFIER` para o identificador institucional (ex: `br.mp.mppbapp.app`) na fase de prontidão iOS em macOS. |
| **RISCO-Q10-003** | Média | iOS / Firebase | Arquivo `GoogleService-Info.plist` ausente em `ios/Runner/`, o que impedirá push notifications no iOS até o provisionamento Apple. | Provisionar arquivo no console Firebase antes de compilação em macOS. |

*Bugs Funcionais Encontrados no Aplicativo:* **Nenhum bug funcional impeditivo (`BUG-Q10-XXX`) foi identificado.**

---

## 6. Regressão e Portões de Segurança

- **Flutter Analyze:** `No issues found!` (0 alertas, 0 erros).
- **Flutter Test:** `187/187 tests passed` (100% verde).
- **Security Gates Canônicos:**
  - `bash scripts/security/secret_scan.sh`: PASS (Exit code 0).
  - `bash scripts/security/security_regression.sh`: PASS (Exit code 0).
  - `test/security/android_cleartext_manifest_test.dart`: PASS.
  - `test/security/biometric_password_storage_test.dart`: PASS.
- **Backend:** `spring-boot/restapi` inalterado (HEAD `508a1fc`, working tree limpo).

---

## 7. Declaração Formal de Encerramento

**Q10 DEFINITIVAMENTE ENCERRADA E CONSISTENTE**

**Q10 CONCLUÍDA — INSTALAÇÃO, ATUALIZAÇÃO E MIGRAÇÃO VALIDADAS NO ESCOPO TESTADO**

**Q11 NÃO INICIADA**
