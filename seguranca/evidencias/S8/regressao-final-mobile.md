# S8 - Evidencia de regressao mobile

Data: 2026-09-24

Escopo: `app_mppb_flutter`

## Comandos previstos

```bash
bash scripts/security/secret_scan.sh
bash scripts/security/security_regression.sh
flutter analyze
flutter test
flutter build apk --debug --flavor homolog -t lib/main.dart
```

## Resultado

| Comando | Resultado |
|---|---|
| `bash scripts/security/secret_scan.sh` | Passou |
| `bash scripts/security/security_regression.sh` | Passou |
| `flutter analyze` | Passou, sem issues |
| `flutter test` | Passou, 114 testes |
| `flutter build apk --debug --flavor homolog -t lib/main.dart` | Passou, gerou `build/app/outputs/flutter-apk/app-homolog-debug.apk` |

## Ajuste de gate

Durante a regressao, o `secret_scan.sh` encontrava o proprio padrao regex dentro do script. A regra foi ajustada para excluir `scripts/security/**` da busca de conteudo, mantendo o escopo de arquivos versionados do app.

## Observacoes

- O pipeline GitLab foi versionado na S7, mas a execucao automatica ficou bloqueada por ausencia de runner ativo no projeto.
- A validacao desta etapa sera local ate a infraestrutura de CI/CD estar disponivel.
- O build Android emitiu aviso de compatibilidade futura do Kotlin Gradle Plugin em plugins `firebase_core` e `share_plus`; nao bloqueia a validacao atual, mas deve entrar no plano de atualizacao de dependencias.
