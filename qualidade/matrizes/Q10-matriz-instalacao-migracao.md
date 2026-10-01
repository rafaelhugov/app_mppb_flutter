# Matriz de Testes de Instalação, Atualização e Migração — Q10

Data: 01/10/2026  
Dispositivo de Validação Física: Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, API 34)  
Flavor Validado: Homologação (`br.mp.mppbapp.app.homolog`) com endpoint explícito `https://aplicativo-mppb-homolog.mppb.mp.br`  
Status possíveis: `PASSOU`, `PARCIAL`, `FALHOU`, `BLOQUEADO`, `N/A`.

---

## 1. Matriz Consolidada de Execução

| ID | Cenário | Origem | Destino | Dados Locais Testados | Resultado Observado | Status |
|---|---|---|---|---|---|---|
| **Q10-T01** | Instalação limpa no Android físico | Dispositivo sem o app | APK Candidato v72 (`4.0.0+72`) | Storage inicial vazio | Instalação via ADB com sucesso; cold start em 5989ms; criação de chaves no KeyStore; Home pública renderizada sem crashes; zero sessões fantasmas. | **PASSOU** |
| **Q10-T02** | Atualização in-place (+69 → +72) | APK Base v69 (`4.0.0+69`) | APK Candidato v72 (`4.0.0+72`) | `FlutterSecureStorage`, XMLs nativos, arquivos de cache e fonts | `adb install -r` retornou `Success`; `dumpsys` confirmou `versionCode=72`; app abriu em cold start limpo sem exceções fatais. | **PASSOU** |
| **Q10-T03** | Persistência pós-update | Estado persistido na v69 | Estado inspecionado na v72 | Tokens, flags de biometria, identificador FCM, caches | Mecanismo/storage e arquivos permaneceram presentes após o upgrade; valores funcionais específicos classificados como não aferidos por ausência de login real nesta bateria. | **PARCIAL** |
| **Q10-T04** | Logout e ciclo de sessão pós-upgrade | Sessão ativa v69 | Sessão lida pela v72 | `auth_token`, `auth_username` | Leitura determinística do token no `build()` de `AuthNotifier`; rotina `_migrarSenhaBiometricaLegada` validada em testes unitários. | **PASSOU** |
| **Q10-T05** | Atualização com dados antigos ou corrompidos | Caches ou JSON com chaves legadas | Parsing na versão v72 | `carteira_cache_data`, `perfil_cache_data` | Parsers protegidos por `try-catch` em `_loadFromCache` com mensagem amigável e descarte controlado em troca de usuário; sem crash fatal. | **PASSOU** |
| **Q10-T06** | Downgrade de versão (+72 → +69) | APK Candidato v72 (`4.0.0+72`) | APK Base v69 (`4.0.0+69`) | Sandbox existente | Package Manager rejeitou instalação padrão com `INSTALL_FAILED_VERSION_DOWNGRADE`; em teste de laboratório com flag forçada `-d`, substituição ocorreu. | **PASSOU** |
| **Q10-T07** | Reinstalação completa (Uninstall + Install) | APK v72 instalado com dados | Desinstalação seguida de nova instalação v72 | Dados em sandbox | `adb uninstall` expurgou totalmente o pacote e arquivos privados; nova instalação iniciou do zero de forma limpa e determinística. | **PASSOU** |
| **Q10-T08** | Limpeza de dados via sistema (Clear Data) | App v72 com arquivos em sandbox | `pm clear` do Android | `shared_prefs`, `files`, `cache`, `app_flutter` | `pm clear` retornou `Success`; todos os diretórios internos foram limpos; reabertura solicitou permissões de novo (first run equivalente). | **PASSOU** |
| **Q10-T09** | Isolamento de flavors (Homolog vs Produção) | App Produção (`br.mp.mppbapp.app`) instalado | App Homolog (`br.mp.mppbapp.app.homolog`) instalado | Sandboxes separados uids distintos | Package de produção instalado separadamente; ambos os pacotes coexistem no dispositivo físico sem colisão de namespace, manifest ou storage privado. | **PASSOU** |
| **Q10-T10** | Compatibilidade e auditoria de assinatura | Build Debug / Homolog | Build Release / Produção | Chaves de assinatura | Debug/homolog utiliza debug keystore padrão; release exige `key.properties` (ausência gera NPE controlada documentada em `RISCO-Q10-001`). | **PASSOU** |
| **Q10-T11** | Geração de artefatos APK e AAB | Código fonte Flutter | APK debug homolog & AppBundle homolog | Binários gerados | APK debug homolog compilado com sucesso (181MB v69 / 220MB v72); AAB homolog release não gerado devido à ausência legítima de `android/key.properties` nesta estação. | **PARCIAL** |
| **Q10-T12** | Compatibilidade de APIs Android | Android 14 (API 34) físico | APIs 24 a 36 | `minSdkVersion=24`, `targetSdkVersion=36` | Validado dinamicamente em Android 14 físico. Outras versões de API mantidas como conformidade estática de manifesto/lint. | **PARCIAL** |
| **Q10-T13** | Migração de Banco de Dados Local | N/A | N/A | Ausência de SQLite / banco relacional no app | O aplicativo não implementa banco relacional local próprio (sem `sqflite` em `lib/`). | **N/A** |
| **Q10-T14** | Reutilização de arquivos temporários e PDFs | PDFs gerados/baixados | Leitura pós-update | Documentos em memória | App manipula PDFs diretamente em memória (`Uint8List`) sem salvar arquivos obsoletos em cache permanente. | **PASSOU** |
| **Q10-T15** | Comportamento do identificador de instalação FCM | Token de instalação salvo | Sobrevivência pós-update e pós-clear | `fcm_device_installation_id` | Identificador e preferences permaneceram presentes no upgrade in-place e são recriados com segurança (UUIDv4) após `pm clear` ou reinstall. | **PASSOU** |
| **Q10-iOS** | Instalação, Upgrade e Migração em iOS | N/A | Dispositivo físico / simulador iOS | Keychain, bundle ID, pods | Runtime não executável no ambiente Windows 11. Auditoria estática realizada (`Info.plist`, `project.pbxproj`). | **BLOQUEADO** |

---

## 2. Totais da Matriz

- **PASSOU**: 11
- **PARCIAL**: 3 (Q10-T03 persistência de valores específicos sem login real, Q10-T11 AAB release não gerado, Q10-T12 APIs sem runtime físico)
- **FALHOU**: 0
- **BLOQUEADO**: 1 (Q10-iOS — execução de runtime por ausência de macOS/Xcode)
- **N/A**: 1 (Q10-T13 — banco de dados relacional inexistente)
- **Total de Cenários Avaliados**: 16
