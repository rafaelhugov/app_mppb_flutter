# Evidência Q10-T03 — Persistência e Integridade Pós-Update

Data: 01/10/2026  
Dispositivo: Samsung Galaxy A52 (SM-A525M, Android 14 / API 34)  
Operação Avaliada: `adb install -r` da versão `4.0.0+69` para `4.0.0+72`

---

## 1. Classificação Metodológica dos Stores e Itens Persistidos

A avaliação empírica de persistência pós-update seguiu o critério estrito de validação: distinguir o que foi comprovado por inspeção de containers e funcionamento operacional do plugin em relação a conteúdos funcionais específicos que demandariam credenciais institucionais reais (não utilizadas nesta bateria).

| Item de Persistência | Store / Tecnologia | Classificação Pós-Update | Detalhamento Técnico |
|---|---|---|---|
| **Chaves Criptográficas KeyStore** | Android KeyStore (`FlutterSecureStoragePluginKeyOAEP`) | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** | Chaves mantidas no KeyStore do SO sob o mesmo UID; o `FlutterSecureStorage` permaneceu operacional após o upgrade sem erros criptográficos. |
| **Token de Autenticação (`auth_token`)** | `FlutterSecureStorage` | **MECANISMO/CONTAINER PRESERVADO / VALOR ESPECÍFICO NÃO AFERIDO** | Contêiner `FlutterSecureStorage.xml` presente e acessível; sem sessão ativa pré-upgrade devido à restrição de não uso de credenciais reais. |
| **Usuário (`auth_username`)** | `FlutterSecureStorage` | **MECANISMO/CONTAINER PRESERVADO / VALOR ESPECÍFICO NÃO AFERIDO** | Contêiner mantido; valor funcional específico não exercitado com login real. |
| **Identificador FCM (`fcm_device_installation_id`)** | `FlutterSecureStorage` | **MECANISMO/CONTAINER PRESERVADO NO UPDATE** | Storage seguro permaneceu íntegro e operacional para geração/leitura do UUIDv4. |
| **Cache Carteira Funcional (`carteira_cache_data`)** | `FlutterSecureStorage` (JSON) | **MECANISMO/CONTAINER PRESERVADO / VALOR ESPECÍFICO NÃO AFERIDO** | Storage seguro íntegro; parser em código com fallback offline comprovado. |
| **Cache Perfil (`perfil_cache_data`)** | `FlutterSecureStorage` (JSON) | **MECANISMO/CONTAINER PRESERVADO / VALOR ESPECÍFICO NÃO AFERIDO** | Storage seguro íntegro; deserialização resiliente em `_loadFromCache`. |
| **Flags Biometria (`biometrics_asked` / `enabled`)** | `FlutterSecureStorage` | **MECANISMO/CONTAINER PRESERVADO / VALOR ESPECÍFICO NÃO AFERIDO** | Contêiner preservado no XML seguro. |
| **Senha Legada (`saved_password`)** | `FlutterSecureStorage` | **REGRA DE CÓDIGO VALIDADA / NÃO EXERCITADA COM VALOR REAL NESTA BATERIA** | A rotina `_migrarSenhaBiometricaLegada` foi validada em testes unitários; valor real não foi injetado nesta bateria de device. |
| **Preferências FCM Nativas** | `com.google.android.gms.appid.xml` | **CONTAINER PRESERVADO** | Arquivo XML permaneceu presente após o upgrade. |
| **Callback Cache Flutter** | `files/flutter_callback_cache.json` | **CONTAINER PRESERVADO** | Arquivo em `files/` permaneceu presente após o upgrade. |
| **Fontes Cacheadas** | `files/Manrope_*.ttf` | **CONTAINER PRESERVADO** | Arquivos de fontes TrueType permaneceram presentes após o upgrade. |
| **Cache Volátil de Imagens** | `cache/` (`flutter_cache_manager`) | **CONTAINER PRESERVADO** | Diretório `cache/` permaneceu presente no sandbox privado após o upgrade. |
| **Arquivos PDF / Relatórios** | N/A (RAM `Uint8List`) | **NÃO AFERIDO / N/A** | O aplicativo não salva PDFs em disco permanente; manipulação ocorre puramente em memória RAM. |
| **Banco Relacional / SQLite** | N/A | **NÃO AFERIDO / N/A** | App não possui SQLite local. |

---

## 2. Auditoria Direta dos Arquivos no Sandbox (Inspecionados via `run-as`)

### Listagem Pré-Update (+69):
```text
shared_prefs/
- FlutterSecureKeyStorage.xml
- FlutterSecureStorage.xml
- FlutterSecureStorageConfiguration:FlutterSecureStorage.xml
- com.google.android.gms.appid.xml
- com.google.firebase.messaging.xml
- io.flutter.firebase.messaging.callback.xml
- io.flutter.plugins.firebase.messaging.permissions.xml
files/
- Manrope_500_*.ttf
- Manrope_regular_*.ttf
- flutter_callback_cache.json
```

### Listagem Pós-Update (+72):
```text
shared_prefs/
- FlutterSecureKeyStorage.xml
- FlutterSecureStorage.xml
- FlutterSecureStorageConfiguration:FlutterSecureStorage.xml
- com.google.android.gms.appid.xml
- com.google.firebase.messaging.xml
- io.flutter.firebase.messaging.callback.xml
- io.flutter.plugins.firebase.messaging.permissions.xml
files/
- Manrope_500_*.ttf
- Manrope_regular_*.ttf
- flutter_callback_cache.json
```

**Conclusão Metodológica**:
Os arquivos do sandbox e as preferências nativas permaneceram presentes após o upgrade, e o plugin `FlutterSecureStorage` permaneceu plenamente operacional na inicialização da versão atualizada, sem falhas de descriptografia ou exceções no Android KeyStore.
