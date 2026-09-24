# S8 - Bloqueios mobile e riscos residuais

Data: 2026-09-24

Escopo: `app_mppb_flutter`.

## Bloqueios

| ID | Bloqueio | Necessario para desbloquear | Impacto |
|---|---|---|---|
| MOB-BLQ-01 | Testes Android dinamicos de filesystem/backup/screenshots | Aparelho/emulador controlado com massa de teste | Confirma armazenamento local e artefatos residuais. |
| MOB-BLQ-02 | Testes iOS/IPA | Ambiente Apple, assinatura e dispositivo/simulador | ATS, Keychain, entitlements e backup iOS ficam parciais. |
| MOB-BLQ-03 | DAST mobile/proxy MITM | Homologacao autorizada e certificado/proxy controlado | Valida TLS, redirects, headers e ausencia de vazamento. |
| MOB-BLQ-04 | SCA/SBOM formal mobile | Runner/ferramenta SCA ou CycloneDX | Classificacao CVE formal ainda pendente. |
| MOB-BLQ-05 | Release assinado/provenance | Chaves protegidas e processo institucional de release | Integridade final do APK/IPA ainda nao demonstrada. |

## Riscos residuais mobile

| Risco | Severidade | Estado | Mitigacao atual | Proxima acao |
|---|---|---|---|---|
| Biometria segura ainda sem novo contrato de credencial revogavel | Media | Aceito temporariamente | Fluxo inseguro desativado; senha nao persiste | Projetar credencial de dispositivo backend. |
| Cache local de carteira/perfil/arquivos sensiveis sem teste dinamico | Media | Parcial | Cache vinculado a usuario; storage seguro para chaves | Testar aparelho e definir limpeza/retencao. |
| iOS nao validado | Media | Bloqueado | Matriz registra parcial | Executar suite iOS quando ambiente existir. |
| Plugins com aviso futuro de Kotlin Gradle Plugin | Baixa/Media | Monitorar | Build atual passa | Planejar atualizacao de `firebase_core` e `share_plus`. |
| Runner GitLab ausente | Media operacional | Bloqueado | Validacao local manual | Habilitar runner ou adaptar pipeline shell. |

## Decisao

O app esta apto a continuar a trilha de seguranca com validacao local, mas nao deve receber declaracao final de prontidao de producao sem resolver ou aceitar formalmente os bloqueios acima.
