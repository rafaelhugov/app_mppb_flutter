# S6 - Gestão de segredos Flutter

Data: 2026-09-24

Branch: `seguranca/s6-gestao-segredos`

## Arquivos sensíveis locais

Arquivos locais encontrados e não rastreados:

- `android/key.properties`
- `android/app/mppbkey.keystore`

Esses arquivos devem ficar fora do Git e ser armazenados em cofre/CI com menor privilégio.

## Arquivos rastreados classificados

- `android/app/google-services.json`
- `lib/firebase_options.dart`

Classificação: configuração pública de cliente Firebase. Não é service account, mas a chave Firebase deve ter restrições por app/package/certificado e APIs no Google Cloud/Firebase.

## Alterações executadas

`.gitignore` passou a bloquear:

- `android/key.properties`
- keystores Android (`*.keystore`, `*.jks`, `*.p12`)
- certificados/chaves (`*.pem`, `*.p8`, `*.cer`)
- provisioning profile (`*.mobileprovision`)

## Secret scan

Working tree:

```bash
rg -n "AIza|-----BEGIN|private_key|client_email|password\s*[:=]|senha\s*[:=]|token\s*[:=]|JCR_PASSWORD|PG_PASSWORD|GOOGLE_APPLICATION_CREDENTIALS|keystore|storePassword|keyPassword" . -S -g '!build/**' -g '!.dart_tool/**' -g '!android/build/**' -g '!**/.gradle/**'
```

Resultado: sem segredo técnico confirmado no código rastreado. Achados classificados:

- API key Firebase de cliente em `google-services.json` e `firebase_options.dart`.
- Referências a keystore no Gradle sem valores de senha.
- Tokens fictícios em testes.

Histórico Git:

```bash
git log --all --name-only --pretty=format: | rg -n "(^|/)(\.env|.*\.env|.*key.*|.*keystore.*|.*credentials.*|.*service-account.*|google-services\.json|GoogleService-Info\.plist|.*\.jks|.*\.p12|.*\.pem|.*\.p8)$" | sort -u
```

Resultado: `android/app/google-services.json` já esteve no histórico, classificado como configuração pública de cliente.

## Pendências operacionais

- Confirmar restrições da API key Firebase/Google Cloud por package name e SHA.
- Confirmar que keystore e senhas de assinatura estão em cofre/variáveis protegidas no CI.
- Em S7, adicionar secret scanning automático no pipeline.
