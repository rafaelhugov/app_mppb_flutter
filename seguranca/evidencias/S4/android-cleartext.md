# S4 - Android cleartext

Data: 2026-09-24

Branch: `seguranca/s4-hardening-producao`

## Objetivo

Garantir que build/release Android não permita tráfego HTTP cleartext global.

## Alterações executadas

- `android/app/src/main/AndroidManifest.xml`
  - `android:usesCleartextTraffic="false"`.
- `android/app/src/debug/AndroidManifest.xml`
  - exceção local `android:usesCleartextTraffic="true"` para desenvolvimento.
- `android/app/src/profile/AndroidManifest.xml`
  - exceção local `android:usesCleartextTraffic="true"` para profile/homologação técnica.

## Validação

Comandos executados:

```bash
flutter test test/security/android_cleartext_manifest_test.dart
flutter test
```

Resultados:

- Teste específico de manifest aprovado.
- Suíte Flutter completa aprovada com 112 testes.

Varredura executada:

```bash
rg -n "usesCleartextTraffic=\"true\"|usesCleartextTraffic=\"false\"" android/app/src -S
```

Resultado:

- `main`: `false`
- `debug`: `true`
- `profile`: `true`

## Rollback

Reverter o commit da S4 restaura o manifest principal com cleartext global.
