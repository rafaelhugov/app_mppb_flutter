# S7 - Pipeline e gates de seguranca do aplicativo Flutter

## Escopo

Branch: `seguranca/s7-pipeline-security-gates`

Repositorio: `app_mppb_flutter`

## Gates adicionados

- `analyze:flutter`: executa `flutter analyze`.
- `test:flutter`: executa a suite completa com `flutter test`.
- `security:secrets`: falha quando arquivos sensiveis ou chaves privadas aparecem versionados.
- `security:regression`: falha quando regressam controles ja corrigidos nas fases S2, S4, S5 e S6.
- `security:android`: executa os testes estaticos de seguranca Android ja versionados em `test/security`.
- `build:android-debug`: gera APK debug controlado apos testes e gates.
- `evidence:dependencies`: gera `dart-deps.json` como evidencia inicial de SCA/SBOM.

## Politica inicial

- Segredo confirmado em arquivo versionado bloqueia o merge.
- Regressao de senha persistida, trafego de token legado/query string ou cleartext habilitado bloqueia o merge.
- `google-services.json` e `GoogleService-Info.plist`, quando presentes, sao tratados como configuracao publica de cliente Firebase; restricoes de API devem ser validadas fora do repositorio.

## Pendencias planejadas

- Evoluir `dart-deps.json` para SBOM CycloneDX formal.
- Integrar SAST dedicado quando a ferramenta corporativa estiver definida.
- Integrar analise estatica de APK/IPA com ferramenta mobile quando a esteira de homologacao estiver disponivel.
