# S5 - Sessão e biometria sem senha persistida

Data: 2026-09-24

Branch: `seguranca/s5-sessao-biometria`

## Decisão arquitetural

O app não deve usar biometria para reutilizar senha salva localmente. Enquanto não existir contrato backend de credencial biométrica revogável, separada da senha e da sessão, o login biométrico fica indisponível.

Proprietário atual da autenticação primária: `auth-api`.

Proprietário da sessão no app: token retornado pelo `auth-api`, armazenado como sessão local em `auth_token`.

## Alterações executadas

- Removida nova gravação de `saved_password`.
- Instalações antigas com `saved_password` passam por migração local:
  - remove `saved_password`;
  - remove `saved_username`;
  - remove `biometrics_enabled`;
  - marca `biometrics_asked=true` para evitar nova oferta automática insegura.
- Login biométrico legado não reutiliza senha salva.
- Perfil deixa de solicitar senha para habilitar biometria.
- Habilitação biométrica informa indisponibilidade até existir credencial segura separada da senha.
- Logout continua removendo `auth_token` e dados de sessão/cache.

## Validação

Comandos executados:

```bash
flutter test test/security/biometric_password_storage_test.dart
flutter test
```

Resultados:

- Teste específico de senha biométrica aprovado.
- Suíte Flutter completa aprovada.

## Pendências controladas da S5

- Definir contrato backend de credencial biométrica revogável.
- Implementar emissão/validação de credencial biométrica sem senha.
- Implementar novo login biométrico usando credencial de dispositivo.
- Testar revogação, expiração, troca de usuário e falhas/cancelamentos de biometria.

## Rollback

Reverter o commit da S5 restaura o comportamento anterior, incluindo risco de persistência de senha em `saved_password`.
