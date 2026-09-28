# Q3 - Regressao

Data: 2026-09-28

## Flutter

- `flutter analyze`: passou, sem issues.
- `flutter test`: passou, 154/154.
- `flutter test --coverage`: passou, 154/154.
- Cobertura LCOV: 3712/10781 linhas, 34,43%.
- `bash scripts/security/secret_scan.sh`: passou, sem saida.
- `bash scripts/security/security_regression.sh`: passou, sem saida.
- `flutter build apk --debug --flavor homolog -t lib/main.dart`: passou.

## Backend

- `bash restapi/mobile-service/scripts/security/secret_scan.sh`: passou, sem saida.
- `bash restapi/mobile-service/scripts/security/security_regression.sh`: passou, sem saida.
- `mvn -q -pl restapi-common,mobile-service test`: passou.
- `mvn -q -pl restapi-common,mobile-service -DskipTests package`: passou.

## Testes adicionados

- Flutter: 11 testes em `test/features/contratos/q3_flutter_backend_contract_test.dart`.
- Backend: 4 testes em `CertidaoExtrajudicialControllerContractTest`.

## Divergencias

- `DIV-Q3-001`: fixture Flutter de Certidao usava `CPF`, mas o contrato real backend/UI e `F|J`. Corrigido para `F`.

