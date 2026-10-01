# Q10 — Inventário de Persistência Local

Data da inspeção: 01/10/2026  
Aplicação: App MPPB (`app_mppb_flutter`)  
Plataformas auditadas: Android (físico Galaxy A52 / API 34) e iOS (auditoria estática de projeto).

---

## 1. Visão Geral da Arquitetura de Persistência

A arquitetura do aplicativo MPPB utiliza armazenamento seguro gerenciado pelo plugin `flutter_secure_storage` (criptografia AES-GCM com chaves no Android KeyStore / iOS Keychain) e cache volátil gerenciado por `flutter_cache_manager` / `cached_network_image`. O aplicativo **não utiliza SQLite** (pacote `sqflite` ausente na camada de domínio/apresentação `lib/`) nem armazena arquivos temporários de forma permanente em disco (PDFs são manipulados em `Uint8List` na memória RAM e despachados diretamente ao sistema via `Printing.sharePdf`).

---

## 2. Inventário Detalhado dos Stores e Artefatos Locais

> **Nota Metodológica de Evidência:** A verificação empírica na bateria de testes de atualização in-place (+69 → +72) no dispositivo físico comprovou que o mecanismo de armazenamento seguro (`FlutterSecureStorage`) permaneceu plenamente operacional, e que os contêineres e arquivos no sandbox permaneceram presentes após o upgrade. Como não foram utilizadas credenciais institucionais reais para autenticação prévia (visando a integridade e segurança de dados pessoais), as chaves funcionais que dependem de sessão autenticada são rigorosamente classificadas quanto à comprovação do container e identificadas com valor específico não aferido nesta bateria.

| Item | Chave / Caminho | Tecnologia | Sensível | Deve sobreviver update? | Deve sobreviver uninstall? | Evidência Pós-Update (+69 → +72) | Comportamento pós-uninstall |
|---|---|---|---|---|---|---|---|
| **Token de Autenticação** | `auth_token` | `FlutterSecureStorage` (EncryptedSharedPreferences / KeyStore) | Sim (Crítico) | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido por ausência de login real) | Removido pelo SO |
| **Login do Usuário** | `auth_username` | `FlutterSecureStorage` | Sim | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido) | Removido pelo SO |
| **Identificador Instalação FCM** | `fcm_device_installation_id` | `FlutterSecureStorage` | Não | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor gerado sob demanda) | Removido / Recriado no first-run |
| **Flag Biometria Habilitada** | `biometrics_enabled` | `FlutterSecureStorage` | Baixo | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido) | Removido pelo SO |
| **Flag Biometria Perguntada** | `biometrics_asked` | `FlutterSecureStorage` | Não | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido) | Removido pelo SO |
| **Cache de Perfil Funcional** | `perfil_cache_data` | `FlutterSecureStorage` (JSON) | Médio | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido) | Removido pelo SO |
| **Usuário do Cache de Perfil** | `perfil_cache_username` | `FlutterSecureStorage` | Sim | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido) | Removido pelo SO |
| **Cache Carteira Funcional** | `carteira_cache_data` | `FlutterSecureStorage` (JSON) | Médio | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido) | Removido pelo SO |
| **Usuário Carteira Funcional** | `carteira_cache_username` | `FlutterSecureStorage` | Sim | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido) | Removido pelo SO |
| **Senha Legada (Descontinuada)** | `saved_password` | `FlutterSecureStorage` | Sim (Crítico) | Não (Expurgada na inicialização) | Não | **REGRA DE CÓDIGO VALIDADA / NÃO EXERCITADA COM VALOR REAL NESTA BATERIA** (Rotina `_migrarSenhaBiometricaLegada`) | Removido |
| **Designações Visualizadas** | `seen_designacoes_<username>` | `FlutterSecureStorage` | Não | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido) | Removido pelo SO |
| **Notificações Lidas** | `read_notification_keys` | `FlutterSecureStorage` | Não | Sim | Não | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** (Valor funcional específico não aferido) | Removido pelo SO |
| **FCM App ID / Preferences** | `com.google.android.gms.appid.xml` | `SharedPreferences` nativo | Não | Sim | Não | **CONTAINER PRESERVADO** (Arquivo XML de 416 bytes presente após upgrade) | Removido pelo SO |
| **FCM Callbacks** | `flutter_callback_cache.json` | Arquivo em `files/` | Não | Sim | Não | **CONTAINER PRESERVADO** (Arquivo de 428 bytes presente após upgrade) | Removido pelo SO |
| **Cache de Imagens/Fotos** | `cache/` | `flutter_cache_manager` em `cache/` | Não | Opcional | Não | **CONTAINER PRESERVADO** (Diretório `cache/` presente após upgrade) | Removido pelo SO |
| **PDFs / Contracheques / Diário** | N/A (Em memória `Uint8List`) | RAM (`PdfPreview` / `Printing`) | Médio | Não | Não | **N/A** (Não persiste em disco) | N/A |
| **Banco Relacional / SQLite** | N/A | N/A (Sem banco de dados local) | N/A | N/A | N/A | **N/A** (Inexistente no aplicativo) | N/A |

---

## 3. Comportamento sob Operações de Ciclo de Vida

1. **Atualização (In-place Upgrade: `adb install -r`)**:
   - O `FlutterSecureStorage` permaneceu operacional após o upgrade: a aplicação inicializou sem erros criptográficos ou perda de chaves.
   - Os arquivos do sandbox (`shared_prefs/`, `files/`, `cache/`) permaneceram presentes após o upgrade.
   - O contêiner de chaves no Android KeyStore (`FlutterSecureStoragePluginKeyOAEP`) permaneceu acessível ao processo da versão atualizada.

2. **Limpeza de Dados (`adb shell pm clear`)**:
   - Todo o sandbox privado é obliterado (diretórios `shared_prefs`, `files`, `cache`, `app_flutter` são removidos).
   - Na primeira reabertura, o app inicializa no estado equivalente à instalação limpa: gera nova chave mestra no KeyStore e solicita novamente permissões de sistema.

3. **Desinstalação Completa (`adb uninstall`)**:
   - O aplicativo e todo o seu armazenamento privado são removidos do dispositivo.
   - As chaves do Android KeyStore associadas ao UID do app são desvinculadas pelo sistema operacional.
   - Nova instalação posterior parte estritamente do zero.
