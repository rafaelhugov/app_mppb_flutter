# Q2 - Relatorio final

Data: 2026-09-28
Branch: `qualidade/q2-testes-componentes`

## Escopo executado

Executada exclusivamente a fase Q2 - Testes Unitarios, Widget e Componentes.

Nao foram iniciadas atividades de Q3, contratos formais, E2E, performance ou endurecimento fora do escopo.

## Alteracoes de codigo

- Corrigida a selecao inicial de data em `ConcessaoAfastamentoCard` para respeitar `selectableDayPredicate`.
- Adicionado `authDioProvider` ao `auth_provider.dart` para permitir teste unitario do login sem chamada real ao endpoint externo.
- Criado `test/helpers/fake_dio.dart` para simular rotas HTTP em testes de providers/repositories.

## Cobertura adicionada

Foram adicionados 29 testes Flutter cobrindo Auth, Carteira, Pagamentos, Diario Oficial, Certidao Extrajudicial, Ouvidoria, Contracheque e Perfil.

Resultado final Flutter:
- Antes da ampliacao Q2: 114 testes.
- Depois da Q2: 143 testes.
- Cobertura LCOV: 3516/10781 linhas, 32,61%.

## Gates finais

Todos os gates finais executados passaram:
- `flutter analyze`
- `flutter test`
- `flutter test --coverage`
- scans de seguranca Flutter
- `flutter build apk --debug --flavor homolog -t lib/main.dart`
- scans de seguranca backend
- `mvn -q -pl restapi-common,mobile-service test`
- `mvn -q -pl restapi-common,mobile-service -DskipTests package`

Observacoes:
- O build Android repetiu o aviso conhecido de plugins que aplicam Kotlin Gradle Plugin (`firebase_core`, `share_plus`).
- O package Maven em paralelo registrou aviso de `/tmp/hsperfdata_rafaelhugo/2` bloqueado por outro processo, mas terminou com exit code 0.

## Runtime Android

O app homolog foi instalado e aberto em emulador Android. A Home publica carregou e foi registrada em screenshot.

Limitacao encontrada:
- `Pixel_8` caiu apos o carregamento inicial com `ERROR | bad color buffer handle 328` e exit code 139.
- `Pixel_9` permaneceu ativo ao final, com `adb devices`, `flutter devices`, boot completo e logcat coletado.

## Artefatos

- `qualidade/matrizes/Q2-cobertura-componentes.md`
- `qualidade/evidencias/Q2/Q2-regressao.md`
- `qualidade/evidencias/Q2/Q2-runtime-android.md`
- `qualidade/evidencias/Q2/android-logcat.txt`
- `qualidade/evidencias/Q2/android-adb-devices.txt`
- `qualidade/evidencias/Q2/android-flutter-devices.txt`
- `qualidade/evidencias/Q2/screenshots/`

## Estado de versionamento

Nao foi criado commit e nao foi feito push, conforme solicitado.

