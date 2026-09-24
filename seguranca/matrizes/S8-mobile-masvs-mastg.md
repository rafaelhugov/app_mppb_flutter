# S8 - Matriz mobile MASVS/MASTG

Data: 2026-09-24

Escopo: `app_mppb_flutter`

Branch: `seguranca/s8-matrizes-rastreabilidade`

## Criterios

- **Coberto**: existe implementacao, teste automatizado ou gate versionado.
- **Parcial**: existe controle implementado, mas falta teste dinamico, aparelho real, iOS ou ferramenta dedicada.
- **Bloqueado**: depende de infraestrutura, ambiente homologado, aparelho real, conta institucional ou ferramenta externa.
- **N/A**: nao aplicavel ao app no estado atual, com justificativa.

## Matriz

| ID | MASVS | Aplicabilidade | Status | Evidencia | Risco residual / proxima acao |
|---|---|---|---|---|---|
| MOB-STO-01 | STORAGE | Tokens, credenciais e dados locais | Coberto | `test/security/biometric_password_storage_test.dart`; `scripts/security/security_regression.sh`; S5/S6 | Manter gate contra `saved_password`. |
| MOB-STO-02 | STORAGE | `flutter_secure_storage`, Keystore/Keychain | Parcial | `pubspec.yaml`; fluxo S5 sem senha persistida | Validar em aparelho Android/iOS real. |
| MOB-STO-03 | STORAGE | Arquivos temporarios, downloads, SQLite | Parcial | Busca estatica e testes de features existentes | Executar exploracao de filesystem em aparelho. |
| MOB-STO-04 | STORAGE | Backup/restore/data extraction | Parcial | Manifest Android inventariado | Testar backup/restore Android e iOS. |
| MOB-STO-05 | STORAGE | Clipboard, snapshot, screenshot | Parcial | Inventario de telas sensiveis | Decidir trade-off UX e aplicar flag quando necessario. |
| MOB-STO-06 | STORAGE | PDFs sensiveis | Parcial | Testes de contracheque/carteira existentes | Testar ciclo de vida de PDF em runtime. |
| MOB-CRY-01 | CRYPTO | Criptografia proprietaria | Coberto | Revisao estatica: uso de libs/plataforma, sem crypto propria identificada | Manter SAST/revisao. |
| MOB-CRY-02 | CRYPTO | Algoritmos fracos | Parcial | Gate de regressao e secret scan | Adicionar SAST dedicado. |
| MOB-CRY-03 | CRYPTO | Segredos hardcoded | Coberto | `scripts/security/secret_scan.sh`; S6 | Validar historico Git quando ferramenta estiver disponivel. |
| MOB-AUT-01 | AUTH | Sessao ativa sem biometria; biometria so apos politica aprovada | Coberto | `test/security/biometric_password_storage_test.dart`; S5 | Biometria segura permanece aguardando credencial de dispositivo. |
| MOB-AUT-02 | AUTH | Biometria nao recupera senha | Coberto | `test/security/biometric_password_storage_test.dart`; `lib/features/auth/providers/auth_provider.dart` | Implementar novo vinculo biometrico sem senha quando backend suportar. |
| MOB-AUT-03 | AUTH | Troca de usuario | Parcial | Fluxo atual limpa senha legada e nao vincula biometria insegura | Criar teste multiusuario quando biometria segura existir. |
| MOB-AUT-04 | AUTH | Falha/cancelamento biometrico | Parcial | Biometria de senha desativada | Testar em aparelho apos novo fluxo biometrico. |
| MOB-AUT-05 | AUTH | Logout e limpeza de sessao | Parcial | Testes de providers e navegacao push | Validar armazenamento local pos-logout em aparelho. |
| MOB-NET-01 | NETWORK | Cleartext em release | Coberto | `test/security/android_cleartext_manifest_test.dart`; `android/app/src/main/AndroidManifest.xml` | iOS ATS ainda precisa matriz especifica. |
| MOB-NET-02 | NETWORK | TLS/hostname/TrustManager permissivo | Parcial | Busca estatica sem TrustManager permissivo conhecido | Executar MITM controlado em homologacao. |
| MOB-NET-03 | NETWORK | Certificate pinning | N/A | Nao adotado no app; decisao depende de threat model | Registrar ADR se for adotado. |
| MOB-NET-04 | NETWORK | Timeouts/redirects sem vazamento | Parcial | Uso de Dio/repositories; token em header Bearer | Testar redirect/proxy/timeout em homologacao. |
| MOB-PLA-01 | PLATFORM | `android:exported` minimo | Parcial | Manifest Android revisado por teste de cleartext | Adicionar auditoria estatica de componentes exportados. |
| MOB-PLA-02 | PLATFORM | Intents/PendingIntents/FileProvider | Parcial | Inventario Android | Teste dinamico Android pendente. |
| MOB-PLA-03 | PLATFORM | Deep links sem acesso autenticado indevido | Parcial | `test/core/notifications/push_navigation_service_test.dart` | Fuzz de URI/deep link pendente. |
| MOB-PLA-04 | PLATFORM | WebView | N/A | Nenhum WebView de negocio identificado nos testes/inventario atual | Revisar se dependencia futura adicionar WebView. |
| MOB-PLA-05 | PLATFORM | Permissoes minimas | Parcial | Manifest Android | Revisao iOS/entitlements pendente. |
| MOB-PLA-06 | PLATFORM | FCM sem PII/navegacao arbitraria | Coberto | `test/core/notifications/push_notification_service_test.dart`; `test/core/notifications/push_navigation_service_test.dart` | Validar payload real em homologacao. |
| MOB-COD-01 | CODE | Build sem debug/endpoints dev | Parcial | S7 build homolog debug; gates de regressao | Validar APK release assinado. |
| MOB-COD-02 | CODE | SCA Flutter/plugins | Parcial | `dart pub deps --json` no pipeline S7 | Evoluir para SCA/CycloneDX formal. |
| MOB-COD-03 | CODE | Parsing/URI/arquivos | Parcial | Testes de processos, concessoes e notificacoes | Adicionar fuzz/property tests onde houver parsing critico. |
| MOB-COD-04 | CODE | Obfuscacao/stripping | Parcial | Build Android atual | Definir politica release/observabilidade. |
| MOB-RES-01 | RESILIENCE | Root/jailbreak | Bloqueado | Requer requisito institucional e aparelho controlado | Definir politica de risco. |
| MOB-RES-02 | RESILIENCE | Hooking/tampering/repackaging | Bloqueado | Requer teste dinamico autorizado | Executar em laboratorio mobile. |
| MOB-RES-03 | RESILIENCE | Assinatura/integridade release | Parcial | `.gitignore` protege keystore; build homolog validado | Validar release assinado e cadeia de artefato. |
| MOB-PRI-01 | PRIVACY | Inventario de dados pessoais | Parcial | S1 inventarios; testes de notificacoes | Consolidar inventario LGPD por funcionalidade. |
| MOB-PRI-02 | PRIVACY | Push/logs/telemetria minimizados | Coberto parcial | Testes FCM sem payload arbitrario/PII tecnico | Captura de trafego e logs reais em homologacao. |
| MOB-PRI-03 | PRIVACY | Retencao/limpeza local | Parcial | Logout/providers testados indiretamente | Teste pos-logout/desinstalacao/restore pendente. |
| MOB-PRI-04 | PRIVACY | SDKs terceiros | Parcial | `pubspec.yaml`, `pubspec.lock`, S6/S7 | Classificar finalidade e dados enviados por SDK. |

## Decisao tecnica desta etapa

Nao ha bloqueador critico novo identificado na matriz local. A prontidao final ainda depende de testes dinamicos em homologacao/aparelho real, validacao iOS e SCA/SAST formais quando a infraestrutura institucional estiver disponivel.
