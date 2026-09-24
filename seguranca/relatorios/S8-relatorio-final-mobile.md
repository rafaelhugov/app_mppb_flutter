# S8 - Relatorio final mobile

Data: 2026-09-24

Escopo: `app_mppb_flutter`.

## Decisao mobile

**GO condicionado para continuidade; NO-GO para declaracao final mobile irrestrita sem testes dinamicos e iOS.**

O app nao apresenta regressao local conhecida de token em URL, senha persistida para biometria ou cleartext em release Android. A suite local passou, incluindo `flutter analyze`, `flutter test` e build `homologDebug`.

## Interpretacao correta da biometria

O ciclo S5 **nao implementou login biometrico seguro final**. O fechamento local confirma somente:

- remocao/desativacao do fluxo inseguro baseado em `saved_password`;
- impedimento de nova persistencia recuperavel da senha institucional;
- teste/gate contra regressao.

O novo mecanismo biometrico seguro permanece como **evolucao funcional futura** e deve usar credencial de dispositivo propria, separada da senha, revogavel e validada pelo backend/auth-api para criar uma nova sessao.

## Evidencias

| Item | Evidencia | Resultado |
|---|---|---|
| Cleartext Android release | `test/security/android_cleartext_manifest_test.dart` | Passou na regressao S8 |
| Biometria sem senha salva | `test/security/biometric_password_storage_test.dart` | Passou na regressao S8 |
| Payload/navegacao FCM | `test/core/notifications/*` | Passou na regressao S8 |
| Secret scan/regressao | `scripts/security/*.sh` | Passou na regressao S8 |
| Build controlado | `flutter build apk --debug --flavor homolog -t lib/main.dart` | Gerou APK homolog debug |
| MASVS/MASTG | `seguranca/matrizes/S8-mobile-masvs-mastg.md` | Parcial com bloqueios formais |
| Threat model mobile | `seguranca/modelos-ameaca/S8-threat-model-mobile.md` | Documentado |

## Bloqueios

| Bloqueio | Impacto |
|---|---|
| iOS/IPA nao validado | ATS, Keychain, entitlements e backup iOS permanecem parciais |
| Aparelho/emulador controlado indisponivel | Storage, backup/restore, screenshots, deep links e filesystem nao foram testados dinamicamente |
| DAST/proxy mobile nao executado | TLS, redirects e vazamento por proxy/APM precisam homologacao |
| SCA/SBOM formal pendente | Vulnerabilidades de plugins/SDKs ainda exigem triagem formal |
| Release assinado/provenance pendente | Integridade final do APK/IPA depende do processo de release |

## Riscos residuais

| Risco | Severidade | Proxima acao |
|---|---|---|
| Biometria segura futura sem credencial revogavel | Media | Definir contrato backend antes de reabilitar |
| Cache local de dados sensiveis sem teste dinamico | Media | Testar aparelho e definir retencao/limpeza |
| iOS sem evidencia | Media | Executar suite iOS |
| SAST dedicado ausente | Media/Alta | Integrar ferramenta institucional; scripts locais nao substituem SAST |
| Aviso futuro de Kotlin Gradle Plugin | Baixa/Media | Planejar atualizacao de `firebase_core` e `share_plus` |

## Conclusao

O app esta apto a continuar a trilha de seguranca com validacao local e gates versionados. Para declaracao final mobile, ainda e obrigatorio executar os testes dinamicos bloqueados e registrar aceite formal dos riscos que permanecerem.
